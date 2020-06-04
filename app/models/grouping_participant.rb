class GroupingParticipant < ApplicationRecord
  self.table_name = "pairings_participants"
  belongs_to :groupings
  belongs_to :participants
end
