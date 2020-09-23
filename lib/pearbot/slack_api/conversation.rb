module Pearbot
  module SlackApi
    class Conversation
      attr_accessor :slack_id

      def initialize(slack_id)
        @slack_id = slack_id
      end

      def self.list_public_channels
        WebClient.new.public_channels_list
      end

      def self.find_info(slack_id)
        WebClient.new.conversation_info(slack_id)
      end

      def self.find_members(slack_id)
        WebClient.new.conversation_members(slack_id)
      end

      def self.open_conversation_for(participants)
        channel = WebClient.new.open_conversation_for(participants)
        Conversation.new(channel.channel.id)
      end
      
      def send_message(text)
        WebClient.new.send_message(text, @slack_id)
      end

      def info
        @info ||= self.class.find_info(slack_id)
      end

      def is_channel?
        !!info.is_channel
      end

      def is_direct_message?
        !!info.is_im
      end

      def is_group_message?
        !!info.is_mpim
      end

      def member_users
        members.reject { |member| member.is_bot? }
      end

      def member_user_ids
        member_users.map(&:slack_id)
      end

      private

      def find_members
        @find_members ||= members = self.class.find_members(slack_id)
      end

      def members
        find_members.map { |member_id| User.new(member_id) }
      end
    end
  end
end
