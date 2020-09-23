require 'rails_helper'

describe Exclusion do
  subject(:exclusion) { FactoryBot.create(:exclusion) }

  it { should belong_to(:excluder) }
  it { should belong_to(:excluded_participant) }

  describe "validations" do
    it { should validate_presence_of(:excluder) }
    it { should validate_presence_of(:excluded_participant) }
  end
end
