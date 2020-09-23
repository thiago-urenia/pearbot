module Pearbot
  module SlackApi
    class WebClient
      def initialize
        Slack.configure do |config|
          config.token = ENV['SLACK_API_TOKEN']
        end
      end

      def conversation_members(conversation)
        client.conversations_members(channel: conversation)
          .fetch(:members)
      end

      def public_channels_list
        client.conversations_list(exclude_archived: true, types: "public_channel")
          .fetch(:channels)
      end

      def conversation_info(conversation)
        client.conversations_info(channel: conversation)
          .fetch(:channel)
      end

      def user_info(user)
        client.users_info(user: user)
          .fetch(:user)
      end

      def open_conversation_for(participants)
        client.conversations_open(users: participants.map(&:slack_user_id).join(','))
      end

      def send_message(text, conversation)
        client.chat_postMessage(text: text, channel: conversation, as_user: true)
      end

      private

      def client
        @client ||= Slack::Web::Client.new
      end
    end
  end
end
