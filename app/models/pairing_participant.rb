class PairingParticipant < ApplicationRecord
  belongs_to :pairings
  belongs_to :participants
end
