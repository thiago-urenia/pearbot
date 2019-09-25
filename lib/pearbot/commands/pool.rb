module Pearbot
  module Commands
    class Pool < SlackRubyBot::Commands::Base
      command 'new pool' do |client, data, _match|
        pool = ::Pool.create(slack_channel: data.channel)
        client.channels.fetch(data.channel).members.each do |member_id|
          user = client.users.fetch(member_id)
          if !user.is_bot
            ::PoolEntry.create(pool: pool, user: ::User.find_or_create_by(slack_id: user.id))
          end
        end

        client.say(channel: data.channel, text: 'Started a new pool')
      end

      command 'destroy pool' do |client, data, _match|
        pool = ::Pool.find_by(slack_channel: data.channel)
        pool.destroy

        client.say(channel: data.channel, text: 'Destroyed the pool')
      end

      command 'new round' do |client, data, _match|
        pool = ::Pool.find_by(slack_channel: data.channel)
        round = ::RoundCreator.new(pool).create
        round.pairings.each do |pairing|
          client.say(channel: data.channel, text: pairing.to_s)
        end
      end

      # command 'check pool' do |client, data, _match|
      #   client.say(channel: data.channel, text: 'ask all pool members if they are available')
      # end

      # command 'join pool' do |client, data, _match|
      #   client.say(channel: data.channel, text: 'invite member to the pool')
      # end

      # command 'leave pool' do |client, data, _match|
      #   client.say(channel: data.channel, text: 'remove member from the pool')
      # end

      # command 'snooze on' do |client, data, _match|
      #   client.say(channel: data.channel, text: 'mark member unavailable for pairing in this pool')
      # end

      # command 'snooze off' do |client, data, _match|
      #   client.say(channel: data.channel, text: 'mark member as available for pairing in this pool')
      # end

      # command 'new round' do |client, data, _match|
      #   client.say(channel: data.channel, text: 'running new round')
      # end
    end
  end
end
