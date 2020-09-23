class Grouping < ApplicationRecord
  belongs_to :round
  has_and_belongs_to_many :participants

  def to_mentions
    Participant.mention_list(participants)
  end

  def to_names
    Participant.name_list(participants)
  end

  def send_intro
    conversation = Pearbot::SlackApi::Conversation.open_conversation_for(participants)
    conversation.send_message("You've been invited to chat by Pearbot!")
  end
end
