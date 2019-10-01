module Pearbot
  module Commands

    class PearbotCommand < SlackRubyBot::Commands::Base
      def self.find_user(client, data, match)
        if match == "me"
          ::Participant.find_by(slack_user_id: data.user)
        else
          ::Participant.find_by(slack_user_id: match)
        end
      end
    end

    class Setup < PearbotCommand
      command /setup/
      command /set up/
      command /new pool/

      help do
        title 'setup'
        desc 'ask me to set up a new pool for the current channel'
        long_desc 'Starts a new pool for the current channel, you should only need to do this once.'
      end

      def self.call(client, data, match)
        pool = ::Pool.new(slack_channel_id: data.channel)

        if pool.save
          pool.load_participants
          client.say(channel: data.channel, text: "✨Started a new pool for <##{data.channel}> with #{pool.participants.count} participants.✨", gif: 'hello')
        else
          client.say(channel: data.channel, text: "🤭A pool for <##{data.channel}> already exists.", gif: 'stuck')
        end
      end
    end

    class Refresh < PearbotCommand
      command /refresh/
      command /reload/
      command /update/
      command /sync/
      command /reset/

      help do
        title 'refresh'
        desc 'ask me to refresh, reload or update the current pool members'
        long_desc 'Updates pool participants to only the current members of the channel. You should run this regularly to clean up the pool. Note this will only remove users who have left the channel from the pool, snoozed users will remain in the pool unless they leave the channel.'
      end

      def self.call(client, data, match)
        pool = ::Pool.find_by(slack_channel_id: data.channel)

        if pool.present?
          pool.refresh_participants
          client.say(channel: data.channel, text: "♻️Refreshing the pool for <##{data.channel}>. There are now #{pool.reload.participants.count} participants", gif: 'reload')
        else
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists.", gif: 'no')
        end
      end
    end

    class Status < PearbotCommand
      command /status/
      command /check.*status/
      command /status.*check/
      command /info.*/
      command /participants/
      command /users/
      command /members/
      command /when/

      help do
        title 'status'
        desc 'ask me for a status check on pool members'
        long_desc 'Displays status information about the pool members and when they were last paired'
      end

      def self.call(client, data, match)
        pool = ::Pool.find_by(slack_channel_id: data.channel)

        if pool.blank?
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists.", gif: 'no')
        else
          client.say(channel: data.channel, text: "💁🏻‍♀️There are currently #{pool.reload.participants.count} participants enrolled in the <##{data.channel}> pool")

          client.say(channel: data.channel, text: "*Available*: #{pool.list_available_participants}") if pool.available_participants.any?
          client.say(channel: data.channel, text: "*Snoozed*: #{pool.list_snoozed_participants}") if pool.snoozed_participants.any?

          if pool.rounds.any?
            client.say(channel: data.channel, text: "🍐We last drew pairs on #{pool.latest_round.created_at.strftime("%A, %d %b %Y at %H:%M")}")
          end

          client.say(channel: data.channel, gif: 'janet')
        end
      end
    end

    class Destroy < PearbotCommand
      command /destroy/
      command /delete/

      help do
        title 'destroy'
        desc 'ask me to destroy the pool'
        long_desc 'Destroys the pool for the current channel. Note: This is destructive and will delete all status information. However, the pool can still be recreated from scratch once destroyed.'
      end

      def self.call(client, data, match)
        pool = ::Pool.find_by(slack_channel_id: data.channel)

        if pool.present?
          pool.destroy
          client.say(channel: data.channel, text: "🔥Destroyed the pool for <##{data.channel}>", gif: 'bye')
        else
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists ", gif: 'no')
        end
      end
    end

    class Pair < PearbotCommand
      command /pair/
      command /pairings/
      command /draw/
      command /run/
      command /next/
      command /round/

      help do
        title 'pair'
        desc 'ask me to draw the next round of pairings'
        long_desc 'Runs a new round of pairing with all active participants from the channel pool. Snoozed partipants will be ignored.'
      end

      def self.call(client, data, match)
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
    end

    class Reminder < PearbotCommand
      command /remind/
      command /reminder/
      command /last/
      command /replay/
      command /repeat/
      command /again/
      command /who .* paired/
      command /who .* pair/

      help do
        title 'remind'
        desc 'ask me to remind you about the last round of pairs'
        long_desc 'Shows the results of the last pairing round again. (Note: this will re-notify folk)'
      end

      def self.call(client, data, match)
        pool = ::Pool.find_by(slack_channel_id: data.channel)

        if pool.blank?
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists.", gif: 'no')
        else

          if pool.rounds.any?
            client.say(
              channel: data.channel,
              text: "🍐We last drew pairs on #{pool.latest_round.created_at.strftime("%A, %d %b %Y at %H:%M")}"
            )

            pool.latest_round.pairings.each do |pairing|
              client.say(channel: data.channel, text: pairing.to_s)
            end

            client.say(channel: data.channel, gif: 'party')

          else
            client.say(channel: data.channel, text: ":dusty_stick: You haven't ran any rounds in <##{data.channel}>", gif: 'duster')
          end
        end
      end
    end

    class Snooze < PearbotCommand
      match /snooze ?(me)/
      match /snooze <@?(\w+)>/


      help do
        title 'snooze me/@user'
        desc 'Ask to be snoozed or snooze another user to temporarily turn off pairing in this pool'
        long_desc 'Temporarily disables pairing for a given user within this channel pool.'
      end

      def self.call(client, data, match)
        pool = ::Pool.find_by(slack_channel_id: data.channel)
        participant = find_user(client, data, match[1])

        if pool.blank?
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists ", gif: 'no')
        elsif participant.blank?
          client.say(channel: data.channel, text: "🙅‍♀️Can't find that user ", gif: 'mystery')
        elsif participant.snooze_pool(pool)
          client.say(channel: data.channel, text: "Snoozed pairing for #{participant.slack_user.real_name} in <##{data.channel}>. 😴", gif: 'sleep')
        end
      end
    end

    class Resume < PearbotCommand
      match /resume ?(me)/
      match /resume <@?(\w+)>/

      help do
        title 'resume me/@user'
        desc 'Ask to resume yourself or another user to turn continue pairing in this pool'
        long_desc 'Re-enables pairing for a given user within this channel pool.'
      end

      def self.call(client, data, match)
        pool = ::Pool.find_by(slack_channel_id: data.channel)
        participant = find_user(client, data, match[1])

        if pool.blank?
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists ", gif: 'no')
        elsif participant.blank?
          client.say(channel: data.channel, text: "🙅‍♀️Can't find that user ", gif: 'mystery')
        elsif participant.resume_pool(pool)
          client.say(channel: data.channel, text: "Resumed pairing for #{participant.slack_user.real_name} in <##{data.channel}>. 😊", gif: 'awake')
        end
      end
    end

  end
end
