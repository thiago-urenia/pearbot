class Pool < ApplicationRecord
  has_many :pool_entries, dependent: :destroy

  has_many :users, through: :pool_entries
  has_many :available_entries, -> { where(status: "available") }, source: :users, class_name: "PoolEntry"
  has_many :rounds

  validates :slack_channel_id, uniqueness: true

  def available_users
    available_entries.map(&:user)
  end

  def find_pairings(round)
    pairings = available_users.shuffle.each_slice(2).to_a
    pairings.each do |pair|
      Pairing.create(round: round, users: pair)
    end
  end
end
