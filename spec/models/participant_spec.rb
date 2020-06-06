require 'rails_helper'

describe Participant do
  subject(:participant) { FactoryBot.create(:participant) }
  let(:pool) { FactoryBot.create(:pool) }

  it { should have_many(:pool_entries) }
  it { should have_many(:pools).through(:pool_entries) }
  it { should have_and_belong_to_many(:groupings) }

  describe "validations" do
    it { should validate_presence_of(:slack_user_id) }
    it { should validate_uniqueness_of(:slack_user_id) }
  end

  describe ".mention_list" do
    subject { described_class.mention_list(participants) }

    context "with 1 participant" do
      let(:participants) {
          [
            FactoryBot.create(:participant)
          ]
        }

      it { is_expected.to eq "#{participants[0].mention}" }
    end

    context "with 2 participants" do
      let(:participants) {
        [
          FactoryBot.create(:participant),
          FactoryBot.create(:participant)
        ]
      }

      it { is_expected.to eq "#{participants[0].mention} and #{participants[1].mention}" }
    end

    context "with 3 participants" do
      let(:participants) {
        [
          FactoryBot.create(:participant),
          FactoryBot.create(:participant),
          FactoryBot.create(:participant)
        ]
      }

      it { is_expected.to eq "#{participants[0].mention}, #{participants[1].mention} and #{participants[2].mention}" }
    end
  end

  describe ".name_list" do
    subject { described_class.name_list(participants) }

    before do
      participants.each do |participant|
        allow(participant).to receive(:slack_user)
          .and_return(double(real_name: Faker::TvShows::Community.characters))
      end
    end

    context "with 1 participant" do
      let(:participants) {
          [
            FactoryBot.create(:participant)
          ]
        }

      it { is_expected.to eq "#{participants[0].name}" }
    end

    context "with 2 participants" do
      let(:participants) {
        [
          FactoryBot.create(:participant),
          FactoryBot.create(:participant)
        ]
      }

      it { is_expected.to eq "#{participants[0].name} and #{participants[1].name}" }
    end

    context "with 3 participants" do
      let(:participants) {
        [
          FactoryBot.create(:participant),
          FactoryBot.create(:participant),
          FactoryBot.create(:participant)
        ]
      }

      it { is_expected.to eq "#{participants[0].name}, #{participants[1].name} and #{participants[2].name}" }
    end
  end

  describe "#name" do
    subject { participant.name }

    let(:slack_user) { double(real_name: Faker::TvShows::Community.characters) }

    before do
      allow(participant).to receive(:slack_user).and_return(slack_user)
    end

    it { is_expected.to eq slack_user.real_name }
  end

  describe "#join_pool" do
    it "creates a new entry for the participant in the given pool" do
      subject.join_pool(pool)
      expect(pool.participants).to include(subject)
    end
  end

  describe "#snooze_pool" do
    it "sets a snoozed status for the participant in the given pool" do
      FactoryBot.create(:pool_entry, :available, participant: subject, pool: pool)
      subject.snooze_pool(pool)

      expect(pool.available_participants).not_to include subject
      expect(pool.snoozed_participants).to include subject
    end
  end

  describe "#resume_pool" do
    it "sets an available status for the participant in the given pool" do
      FactoryBot.create(:pool_entry, :snoozed, participant: subject, pool: pool)
      subject.resume_pool(pool)

      expect(pool.available_participants).to include subject
      expect(pool.snoozed_participants).not_to include subject
    end
  end

  describe "#leave_pool" do
    it "removes the participant from the given pool" do
      FactoryBot.create(:pool_entry, participant: subject, pool: pool)
      subject.leave_pool(pool)

      expect(pool.participants).not_to include(subject)
    end
  end
end
