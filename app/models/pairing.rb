class Pairing < ApplicationRecord
  belongs_to :round
  has_and_belongs_to_many :users


  def to_s
    # users.map(&:slack_user_id)
    mentions = users.map{ |user| "<@#{user.slack_user_id}>" }
    mentions.to_sentence
    # mentions.join(" & ")
  end
end
