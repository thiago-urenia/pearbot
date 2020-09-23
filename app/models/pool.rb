class Pool < ApplicationRecord
  has_many :pool_entries, dependent: :destroy

  has_many :participants, through: :pool_entries
  has_many :available_entries, -> { where(status: :available) }, source: :participants, class_name: "PoolEntry"
  has_many :snoozed_entries, -> { where(status: :snoozed) }, source: :participants, class_name: "PoolEntry"

  has_many :rounds

  validates :slack_channel_id, presence: true, uniqueness: true

  def self.find_by_channel_id_and_refresh(slack_channel_id)
    pool = find_by(slack_channel_id: slack_channel_id)
    pool.refresh_participants if pool.present?
    pool
  end

  def slack_channel
    Pearbot::SlackApi::Conversation.new(slack_channel_id)
  end

  def load_participants
    add(slack_channel.member_user_ids)
  end

  def refresh_participants
    participant_ids = participants.map(&:slack_user_id)

    leavers = participant_ids - slack_channel.member_user_ids
    remove(leavers)

    joiners = slack_channel.member_user_ids - participant_ids
    add(joiners)
  end

  def available_participants
    available_entries.map(&:participant)
  end

  def list_available_participants
    Participant.name_list(available_participants)
  end

  def snoozed_participants
    snoozed_entries.map(&:participant)
  end

  def list_snoozed_participants
    Participant.name_list(snoozed_participants)
  end

  def latest_round
    rounds.last
  end

  private

  def remove(user_ids)
    user_ids.each do |user_id|
      participant = Participant.find_by(slack_user_id: user_id)
      participant.leave_pool(self)
    end
  end

  def add(user_ids)
    user_ids.each do |user_id|
      participant = Participant.find_or_create_by(slack_user_id: user_id)
      participant.join_pool(self)
    end
  end
end
