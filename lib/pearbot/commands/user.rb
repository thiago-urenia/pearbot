module Pearbot
  module Commands
    class User < SlackRubyBot::Commands::Base
      command 'history' do |client, data, _match|
        client.say(channel: data.channel, text: 'show my pairing history')
      end

      command 'reminder' do |client, data, _match|
        client.say(channel: data.channel, text: 'show my latest pairings')
      end

      command 'pools' do |client, data, _match|
        client.say(channel: data.channel, text: 'show my pools')
      end
    end
  end
end
