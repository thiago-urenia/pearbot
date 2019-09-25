module Pearbot
  class SlackClient
    def initialize
      Slack.configure do |config|
        config.token = ENV['SLACK_API_TOKEN']
      end
    end

    private

    def client
      @client ||= Slack::Web::Client.new
    end
  end
end
