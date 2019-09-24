class PoolEntry < ApplicationRecord
  belongs_to :user
  belongs_to :pool

  scope :available, -> { where(status: 'available') }
end
