module Pearbot
  module Commands
    class Debug < SlackRubyBot::Commands::Base
      command 'calculate' do |client, data, _match|
        client.say(channel: data.channel, text: '4')
      end
    end
  end
end
