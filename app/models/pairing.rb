class Pairing < ApplicationRecord
  belongs_to :round
  has_and_belongs_to_many :participants

  def to_s
    Participant.mention_list(participants)
  end
end
