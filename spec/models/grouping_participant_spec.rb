require 'rails_helper'

describe GroupingParticipant do
  it { should belong_to(:grouping) }
  it { should belong_to(:participant) }
end
