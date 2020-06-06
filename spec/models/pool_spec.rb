require 'rails_helper'

describe Pool do
  subject(:pool) { FactoryBot.create(:pool) }

  describe "associations" do
    it { should have_many(:pool_entries) }
    it { should have_many(:participants).through :pool_entries }
    it { should have_many(:available_entries) }
    it { should have_many(:snoozed_entries) }

    it { should have_many(:rounds) }
  end

  describe "validations" do
    it { should validate_presence_of(:slack_channel_id) }
    it { should validate_uniqueness_of(:slack_channel_id) }
  end

  let(:slack_channel) do
    double(
      slack_id: "slack_id",
      info: "info",
      member_user_ids: %w(member_1_id, member_2_id, member_3_id)
    )
  end

  before do
    allow(pool).to receive(:slack_channel).and_return(slack_channel)
  end

  describe "#load_participants" do
    context "for participants who are already known to the database" do
      before do
        slack_channel.member_user_ids.each do |id|
          FactoryBot.create(:participant, slack_user_id: id)
        end
      end

      it "does not create any new participant record" do
        expect { pool.load_participants }.not_to change { Participant.count }
      end

      it "adds all participants to the pool" do
        pool.load_participants
        expect(pool.participants.pluck(:slack_user_id)).to eq slack_channel.member_user_ids
      end
    end

    context "for brand new participants" do
      it "does not create any new participant record" do
        expect { pool.load_participants }.to change { Participant.count }.by(3)
      end

      it "adds all participants to the pool" do
        pool.load_participants
        expect(pool.participants.pluck(:slack_user_id)).to eq slack_channel.member_user_ids
      end
    end
  end

  describe "#refresh_participants" do
    let(:initial_channel_members) { %w(original_member_1_id, original_member_2_id, original_member_3_id) }
    let(:updated_channel_members) { %w(original_member_1_id, new_member_id) }

    it "refreshes initially loaded participants to match current channel membership" do
      allow(pool).to receive(:slack_channel).and_return(double(member_user_ids: initial_channel_members))
      pool.load_participants
      expect(pool.participants.pluck(:slack_user_id)).to eq initial_channel_members

      allow(pool).to receive(:slack_channel).and_return(double(member_user_ids: updated_channel_members))
      pool.refresh_participants
      expect(pool.participants.reload.pluck(:slack_user_id)).to eq updated_channel_members
    end
  end

  describe "#available_participants" do
    subject { pool.available_participants }

    let(:available_participant_1) { FactoryBot.create(:participant) }
    let(:available_participant_2) { FactoryBot.create(:participant) }
    let(:snoozed_participant_1) { FactoryBot.create(:participant) }
    let(:snoozed_participant_2) { FactoryBot.create(:participant) }

    before do
      available_participant_1.join_pool(pool)
      available_participant_2.join_pool(pool)
      snoozed_participant_1.join_pool(pool).snooze
      snoozed_participant_2.join_pool(pool).snooze
    end

    it { is_expected.to eq [available_participant_1, available_participant_2]}
  end

  describe "#snoozed_participants" do
    subject { pool.snoozed_participants }

    let(:available_participant_1) { FactoryBot.create(:participant) }
    let(:available_participant_2) { FactoryBot.create(:participant) }
    let(:snoozed_participant_1) { FactoryBot.create(:participant) }
    let(:snoozed_participant_2) { FactoryBot.create(:participant) }

    before do
      available_participant_1.join_pool(pool)
      available_participant_2.join_pool(pool)
      snoozed_participant_1.join_pool(pool).snooze
      snoozed_participant_2.join_pool(pool).snooze
    end

    it { is_expected.to eq [snoozed_participant_1, snoozed_participant_2]}
  end


  describe "#latest_round" do
    subject { pool.latest_round }

    before do
      2.times { FactoryBot.create(:round, pool: pool) }
    end

    it { is_expected.to eq Round.last }
  end
end
