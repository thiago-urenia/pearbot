module Pearbot
  module Commands
    class Pool < SlackRubyBot::Commands::Base
      command 'new pool' do |client, data, _match|
        pool = ::Pool.new(slack_channel_id: data.channel)

        if pool.save
          client.channels.fetch(data.channel).members.each do |member_id|
            user = client.users.fetch(member_id)
            if !user.is_bot
              ::PoolEntry.create(pool: pool, participant: ::Participant.find_or_create_by(slack_user_id: user.id))
            end
          end

          client.say(channel: data.channel, text: "Started a new pool for <##{data.channel}> with #{pool.participants.count} participants", gif: 'ready')
        else
          client.say(channel: data.channel, text: "A pool for <##{data.channel}> already exists.")
        end
      end

      command 'destroy pool' do |client, data, _match|
        pool = ::Pool.find_by(slack_channel_id: data.channel)

        if pool.destroy
          client.say(channel: data.channel, text: "Destroyed the pool for <##{data.channel}>", gif: 'destroy')
        else
          client.say(channel: data.channel, text: "No pool for <##{data.channel}> exists", gif: 'destroy')
        end
      end

      command 'new round' do |client, data, _match|
        pool = ::Pool.find_by(slack_channel_id: data.channel)

        if round = ::RoundCreator.new(pool).create
          client.say(channel: data.channel, text: "The next round of pairs are: ", gif: 'friendship')
          round.pairings.each do |pairing|
            client.say(channel: data.channel, text: pairing.to_s)
          end
        end
      end

      command 'snooze' do |client, data, _match|
        pool = ::Pool.find_by(slack_channel_id: data.channel)
        participant = ::Participant.find_by(slack_user_id: data.user)
        entry = ::PoolEntry.find_by(pool: pool, participant: participant)
        if entry.update_attributes(status: 'unavailable')
          client.say(channel: data.channel, text: "We've snoozed pairing for you", gif: 'sleep')
        end
      end

      command 'resume' do |client, data, _match|
        pool = ::Pool.find_by(slack_channel_id: data.channel)
        participant = ::Participant.find_by(slack_user_id: data.user)
        entry = ::PoolEntry.find_by(pool: pool, participant: participant)
        if entry.update_attributes(status: 'available')
          client.say(channel: data.channel, text: "We've enabled pairing for you", gif: 'alert')
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
