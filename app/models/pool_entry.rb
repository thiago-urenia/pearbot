class PoolEntry < ApplicationRecord
  belongs_to :participant
  belongs_to :pool

  scope :available, -> { where(status: :available) }
  scope :snoozed, -> { where(status: :snoozed) }

  SNOOZED = "snoozed".freeze
  AVAILABLE = "available".freeze

  def snooze
    update(status: SNOOZED)
  end

  def resume
    update(status: AVAILABLE)
  end
end
