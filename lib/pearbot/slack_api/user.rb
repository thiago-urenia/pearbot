module Pearbot
  module SlackApi
    class User
      attr_accessor :slack_id

      def initialize(slack_id)
        @slack_id = slack_id
      end

      def self.find_info(slack_id)
        WebClient.new.user_info(slack_id)
      end

      def info
        self.class.find_info(slack_id)
      end

      def is_bot?
        info.is_bot
      end

      def real_name
        info.real_name
      end
    end
  end
end
