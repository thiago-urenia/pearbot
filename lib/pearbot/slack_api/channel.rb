module Pearbot
  module SlackApi
    class Channel
      attr_accessor :slack_id

      def initialize(slack_id)
        @slack_id = slack_id
      end

      def self.find_info(slack_id)
        WebClient.new.channel_info(slack_id)
      end

      def info
        self.class.find_info(slack_id)
      end

      def member_user_ids
        member_users.map(&:slack_id)
      end

      def member_users
        members.reject { |member| member.is_bot? }
      end

      private

      def members
        info.members.map { |member_id| User.new(member_id) }
      end
    end
  end
end
