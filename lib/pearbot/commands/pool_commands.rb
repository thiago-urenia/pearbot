module Pearbot
  module Commands
    class PoolCommands < SlackRubyBot::Commands::Base
      command 'setup' do |client, data, _match|
        pool = ::Pool.new(slack_channel_id: data.channel)

        if pool.save
          pool.load_participants
          client.say(channel: data.channel, text: "✨Started a new pool for <##{data.channel}> with #{pool.participants.count} participants.✨", gif: 'hello')
        else
          client.say(channel: data.channel, text: "🤭A pool for <##{data.channel}> already exists.", gif: 'stuck')
        end
      end

      command 'destroy' do |client, data, _match|
        pool = ::Pool.find_by(slack_channel_id: data.channel)

        if pool.present?
          pool.destroy
          client.say(channel: data.channel, text: "🔥Destroyed the pool for <##{data.channel}>", gif: 'bye')
        else
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists ", gif: 'no')
        end
      end

      command 'pair' do |client, data, _match|
        pool = ::Pool.find_by(slack_channel_id: data.channel)

        if pool.blank?
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists ", gif: 'no')

        elsif pool.available_participants.count == 1
          participant = pool.available_participants.first
          client.say(channel: data.channel, text: "<@#{participant.slack_user_id}> looks like you're on your own 😶", gif: 'alone')

        elsif round = ::RoundCreator.new(pool).create
          client.say(channel: data.channel, text: "👯‍♀️The next round of pairs are: ")

          round.pairings.each do |pairing|
            client.say(channel: data.channel, text: pairing.to_s)
          end

          client.say(channel: data.channel, gif: 'friendship')
        end
      end

      command 'snooze me' do |client, data, _match|
        pool = ::Pool.find_by(slack_channel_id: data.channel)

        if pool.blank?
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists ", gif: 'no')
        else
          participant = ::Participant.find_by(slack_user_id: data.user)
          entry = ::PoolEntry.find_by(pool: pool, participant: participant)
          if entry.update_attributes(status: 'unavailable')
            client.say(channel: data.channel, text: "<@#{participant.slack_user_id}> we've snoozed pairing for you in <##{data.channel}>. 😴", gif: 'sleep')
          end
        end
      end

      command 'resume me' do |client, data, _match|
        pool = ::Pool.find_by(slack_channel_id: data.channel)

        if pool.blank?
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists ", gif: 'no')
        else
          participant = ::Participant.find_by(slack_user_id: data.user)
          entry = ::PoolEntry.find_by(pool: pool, participant: participant)
          if entry.update_attributes(status: 'available')
            client.say(channel: data.channel, text: "<@#{participant.slack_user_id}> we've resuming pairing for you in <##{data.channel}>. 😊", gif: 'alert')
          end
        end
      end

    end
  end
end
