require 'rails_helper'

describe "commands" do
  let(:bot) { SlackRubyBot.config.user }

  describe Pearbot::PearbotCommand do
    describe ".replace_me_with_id" do
      let(:current_user_id) { "current-user-id" }
      subject { described_class.replace_me_with_id(parsed_id, current_user_id) }

      context "when matches me" do
        let(:parsed_id) { "me" }
        it { is_expected.to eq current_user_id }
      end

      context "not not matching me" do
        let(:parsed_id) { "rando" }
        it { is_expected.to eq parsed_id }
      end
    end
  end
end

