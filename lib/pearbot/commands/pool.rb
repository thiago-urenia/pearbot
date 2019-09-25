module Pearbot
  module Commands
    class Pool < SlackRubyBot::Commands::Base
      command 'new pool' do |client, data, _match|
        client.say(channel: data.channel, text: 'setting up a new pool from the channel')
      end

      command 'check pool' do |client, data, _match|
        client.say(channel: data.channel, text: 'ask all pool members if they are available')
      end

      command 'join pool' do |client, data, _match|
        client.say(channel: data.channel, text: 'invite member to the pool')
      end

      command 'leave pool' do |client, data, _match|
        client.say(channel: data.channel, text: 'remove member from the pool')
      end

      command 'snooze on' do |client, data, _match|
        client.say(channel: data.channel, text: 'mark member unavailable for pairing in this pool')
      end

      command 'snooze off' do |client, data, _match|
        client.say(channel: data.channel, text: 'mark member as available for pairing in this pool')
      end

      command 'new round' do |client, data, _match|
        client.say(channel: data.channel, text: 'running new round')
      end
    end
  end
end
