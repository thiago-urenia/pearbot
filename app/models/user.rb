class User < ApplicationRecord
  has_many :pool_entries
  has_many :pools, through: :pool_entries
  has_and_belongs_to_many :pairings
end
