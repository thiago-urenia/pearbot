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

      def self.format_date_time(timestamp)
        unix = timestamp.to_i
        fallback = timestamp.strftime("%A, %B #{timestamp.day.ordinalize}, %Y at %H.%M UTC")

        "<!date^#{unix}^{date_long_pretty} at {time}|#{fallback}>"
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
          message = "✨Started a new pool for <##{data.channel}> with #{pool.participants.count} participants.✨"
          message += "\n> #{Participant.name_list(pool.participants)}" if pool.participants.any?
          client.say(channel: data.channel, text: message, gif: 'hello')

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
          message = "♻️Refreshing the pool for <##{data.channel}>."
          message += "\nThere are now #{pool.reload.participants.count} participants"
          message += "\n> #{Participant.name_list(pool.participants)}" if pool.participants.any?
          client.say(channel: data.channel, text: message, gif: 'reload')
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
          summary = ":janet: There are currently #{pool.reload.participants.count} participants enrolled in the <##{data.channel}> pool"
          summary += "\n> 👋 *Available*: #{pool.list_available_participants}" if pool.available_participants.any?
          summary += "\n> 🛌 *Snoozed*: #{pool.list_snoozed_participants}" if pool.snoozed_participants.any?
          summary += "\n🍐 Last drew pairs: #{format_date_time(pool.latest_round.created_at)}" if pool.rounds.any?

          client.say(channel: data.channel, text: summary, gif: 'janet')
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
      command /new pair.*/
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

        elsif pool.available_participants.empty?
          client.say(channel: data.channel, text: ":dusty_stick: Looks like nobody's available for pairing", gif: 'duster')

        elsif pool.available_participants.count == 1
          participant = pool.available_participants.first
          client.say(channel: data.channel, text: "<@#{participant.slack_user_id}> looks like you're on your own 😶", gif: 'alone')

        elsif round = ::RoundCreator.new(pool).create
          formatted_pairings = round.pairings.map(&:to_mentions).join("\n")

          client.say(
            channel: data.channel,
            text: "👯‍♀️The next round of pairs are:\n#{formatted_pairings}",
            gif: 'friendship'
          )
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
        long_desc 'Shows the results of the last pairing round again.'
      end

      def self.call(client, data, match)
        pool = ::Pool.find_by(slack_channel_id: data.channel)

        if pool.blank?
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists.", gif: 'no')
        elsif pool.rounds.any?
          formatted_pairings = pool.latest_round.pairings.map { |pairing| "> #{pairing.to_names}" }.join("\n")
          client.say(
            channel: data.channel,
            text: "🍐Last drew pairs: #{format_date_time(pool.latest_round.created_at)}\n#{formatted_pairings}",
            gif: 'party'
          )
        else
          client.say(channel: data.channel, text: ":dusty_stick: You haven't ran any rounds in <##{data.channel}>", gif: 'duster')
        end
      end
    end

    class Snooze < PearbotCommand
      match /snooze ?(me)/
      match /snooze <@?(\w+)>/


      help do
        title 'snooze me/@user'
        desc 'ask to be snoozed or snooze another user to temporarily turn off pairing in this pool'
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
        desc 'ask to resume yourself or another user to continue pairing in this pool'
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
