class Round < ApplicationRecord
  belongs_to :pool
  has_many :groupings
end
