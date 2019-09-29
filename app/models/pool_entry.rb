class PoolEntry < ApplicationRecord
  belongs_to :participant
  belongs_to :pool

  scope :available, -> { where(status: 'available') }
end
