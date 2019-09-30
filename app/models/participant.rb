class Participant < ApplicationRecord
  has_many :pool_entries
  has_many :pools, through: :pool_entries
  has_and_belongs_to_many :pairings

  validates :slack_user_id, presence: true, uniqueness: true


  def self.mention_list(participants)
    mentions = participants.map{ |participant| "<@#{participant.slack_user_id}>" }
    mentions.to_sentence
  end

  def slack_user
    Pearbot::SlackApi::User(slack_user_id)
  end

  def join_pool(pool)
    PoolEntry.create(participant: self, pool: pool)
  end

  def snooze_pool(pool)
    entry(pool).snooze
  end

  def resume_pool(pool)
    entry(pool).resume
  end

  def leave_pool(pool)
    entry(pool).destroy
  end

  private

  def entry(pool)
    PoolEntry.find_by(participant: self, pool: pool)
  end

  def client
    @client ||= Pearbot::SlackWebClient.new
  end
end
