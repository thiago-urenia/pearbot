class PairingUser < ApplicationRecord
  belongs_to :pairings
  belongs_to :users
end
