require 'rails_helper'

RSpec.describe Participant, type: :model do
  subject { FactoryBot.create(:participant) }

  describe "validations" do
    it { should validate_presence_of(:slack_user_id) }
    it { should validate_uniqueness_of(:slack_user_id) }
  end
end
