require 'rails_helper'

describe Pearbot::SlackApi::User do
  subject(:user) { described_class.new "slack_id" }

  let(:is_bot) { false }

  let(:user_info_double) do
    double(
      is_bot: is_bot,
      real_name: "Britta Perry"
    )
  end

  before do
    allow(described_class).to receive(:find_info).and_return(user_info_double)
  end

  describe "#slack_id" do
    subject { user.slack_id }
    it { is_expected.to eq "slack_id" }
  end

  describe "#info" do
    subject { user.info }
    it { is_expected.to eq user_info_double }
  end

  describe "#is_bot?" do
    subject { user.is_bot? }
    context "for a human user" do
      it { is_expected.to be false }
    end

    context "for a bot user" do
      let(:is_bot) { true }
      it { is_expected.to be true }
    end
  end

  describe "#real_name" do
    subject { user.real_name }
    it { is_expected.to eq "Britta Perry" }
  end
end
