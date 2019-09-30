class PoolEntry < ApplicationRecord
  belongs_to :participant
  belongs_to :pool

  scope :available, -> { where(status: :available) }
  scope :snoozed, -> { where(status: :snoozed) }

  def snooze
    update(status: :snoozed)
  end

  def resume
    update(status: :available)
  end
end
