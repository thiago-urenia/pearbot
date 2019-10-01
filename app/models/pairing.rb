class Pairing < ApplicationRecord
  belongs_to :round
  has_and_belongs_to_many :participants

  def to_mentions
    Participant.mention_list(participants)
  end

  def to_names
    Participant.name_list(participants)
  end
end
