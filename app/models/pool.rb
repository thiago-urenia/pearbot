class Pool < ApplicationRecord
  has_many :pool_entries, dependent: :destroy

  has_many :participants, through: :pool_entries
  has_many :available_entries, -> { where(status: "available") }, source: :participants, class_name: "PoolEntry"
  has_many :rounds

  validates :slack_channel_id, uniqueness: true

  def available_participants
    available_entries.map(&:participant)
  end

  def find_pairings(round)
    pairings = available_participants.shuffle.each_slice(2).to_a
    pairings.each do |pair|
      Pairing.create(round: round, participants: pair)
    end
  end
end
