class Pool < ApplicationRecord
  has_many :pool_entries, dependent: :destroy

  has_many :participants, through: :pool_entries
  has_many :available_entries, -> { where(status: "available") }, source: :participants, class_name: "PoolEntry"
  has_many :rounds

  validates :slack_channel_id, uniqueness: true

  def slack_channel
    Pearbot::SlackApi::Channel.new(slack_channel_id)
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

  def find_pairings(round)
    pairings = available_participants.shuffle.each_slice(2).to_a
    pairings.each do |pair|
      Pairing.create(round: round, participants: pair)
    end
  end

  private

  def client
    @client ||= Pearbot::SlackWebClient.new
  end

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
