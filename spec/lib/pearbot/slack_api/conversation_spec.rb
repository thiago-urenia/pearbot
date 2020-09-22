require 'rails_helper'

describe Pearbot::SlackApi::Conversation do
  subject(:channel) { described_class.new "slack_id" }

  let(:human) { double(slack_id: "human_member_id", is_bot?: false) }
  let(:bot) { double(slack_id: "bot_member_id", is_bot?: true) }


  let(:channel_info_double) do
    double(
      members: [human.slack_id, bot.slack_id]
    )
  end

  before do
    allow(described_class).to receive(:find_info).and_return(channel_info_double)
    allow(channel).to receive(:members).and_return([human,bot])
  end

  describe "#slack_id" do
    subject { channel.slack_id }
    it { is_expected.to eq "slack_id" }
  end

  describe "#info" do
    subject { channel.info }
    it { is_expected.to eq channel_info_double }
  end

  describe "#member_user_ids" do
    subject { channel.member_user_ids }

    before do
      allow(channel).to receive(:members).and_return([human,bot])
    end

    it { is_expected.to eq [human.slack_id] }
  end

  describe "#member_users" do
    subject { channel.member_users }
    it { is_expected.to eq [human] }
  end
end
