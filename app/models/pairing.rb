class Pairing < ApplicationRecord
  belongs_to :round
  has_and_belongs_to_many :participants


  def to_s
    mentions = participants.map{ |participant| "<@#{participant.slack_user_id}>" }
    mentions.to_sentence
  end
end
