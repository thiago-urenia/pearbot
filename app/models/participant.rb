class Participant < ApplicationRecord
  has_many :pool_entries
  has_many :pools, through: :pool_entries

  has_many :exclusions, foreign_key: "excluder"
  has_many :excluders, through: :exclusions, class_name: "Participant"
  has_many :excluded_participants, through: :exclusions, class_name: "Participant"

  has_and_belongs_to_many :groupings

  validates :slack_user_id, presence: true, uniqueness: true

  def self.mention_list(participants)
    mentions = participants.map{ |participant| participant.mention }
    mentions.to_sentence(last_word_connector: " and ")
  end

  def self.name_list(participants)
    names = participants.map{ |participant| "#{participant.name}" }
    names.to_sentence(last_word_connector: " and ")
  end

  def slack_user
    Pearbot::SlackApi::User.new(slack_user_id)
  end

  def mention
    "<@#{slack_user_id}>"
  end

  def name
    "*#{slack_user.real_name}*"
  end

  def in_pool?(pool)
    pools.include?(pool) if pool.present?
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

  def exclusions_list
    return nil unless excluded_participants.any?
    self.class.name_list(excluded_participants)
  end

  private

  def entry(pool)
    PoolEntry.find_by(participant: self, pool: pool)
  end
end
