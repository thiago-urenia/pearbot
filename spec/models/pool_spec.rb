require 'rails_helper'

RSpec.describe Pool, type: :model do
  subject { FactoryBot.create(:pool) }

  describe "validations" do
    it { should validate_presence_of(:slack_channel_id) }
    it { should validate_uniqueness_of(:slack_channel_id) }
  end
end
