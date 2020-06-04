class GroupingParticipant < ApplicationRecord
  self.table_name = "groupings_participants"
  belongs_to :grouping
  belongs_to :participant
end
