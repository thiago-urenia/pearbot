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
    conversation.send_message("You've been paired by @pearbot! 🥳 \n What's next? Set up a 121 to catch up with each other. https://media.giphy.com/media/L0NBGdEtE8tUP6MVwH/giphy.gif")
  end
end
