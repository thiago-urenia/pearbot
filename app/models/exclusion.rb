class Exclusion < ApplicationRecord
  belongs_to :excluder, class_name: "Participant"
  belongs_to :excluded_participant, class_name: "Participant"

  validates :excluder, presence: true
  validates :excluded_participant, presence: true
end

