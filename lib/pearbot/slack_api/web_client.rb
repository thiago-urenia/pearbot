module Pearbot
  module SlackApi
    class WebClient
      def initialize
        Slack.configure do |config|
          config.token = ENV['SLACK_API_TOKEN']
        end
      end

      def channel_info(channel)
        client.channels_info(channel: channel)
          .fetch(:channel)
      end

      def user_info(user)
        client.users_info(user: user)
          .fetch(:user)
      end

      private

      def client
        @client ||= Slack::Web::Client.new
      end
    end
  end
end
