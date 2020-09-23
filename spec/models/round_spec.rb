require 'rails_helper'

describe Round do
  it { should belong_to(:pool) }
  it { should have_many(:groupings) }
end
