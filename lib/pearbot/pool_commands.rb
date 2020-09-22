module Pearbot
  module PoolCommands

    class Setup < PearbotCommand
      command /setup/

      help do
        title 'setup'
        desc 'Start a new drawing pool for the current channel, you will only need to do setup the pool once.'
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

      help do
        title 'refresh'
        desc 'Refresh the pool so it matches the current members of the channel. You should run this regularly to clean up the pool. Note this will only remove users who have left the channel from the pool, snoozed users will remain in the pool unless they leave the channel.'
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

      help do
        title 'status'
        desc 'Display status information about the pool members and when they were last drawn.'
      end

      def self.call(client, data, match)
        pool = Pool.find_by_channel_id_and_refresh(data.channel)

        if pool.blank?
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists.", gif: 'no')
        else
          summary = ":janet: There are currently #{pool.reload.participants.count} participants enrolled in the <##{data.channel}> pool"
          summary += "\n> 👋 *Available*: #{pool.list_available_participants}" if pool.available_participants.any?
          summary += "\n> 🛌 *Snoozed*: #{pool.list_snoozed_participants}" if pool.snoozed_participants.any?
          summary += "\n🍐 Last draw: #{format_date_time(pool.latest_round.created_at)}" if pool.rounds.any?

          client.say(channel: data.channel, text: summary, gif: 'janet')
        end
      end
    end
    class Destroy < PearbotCommand
      command /destroy/

      help do
        title 'destroy'
        desc 'Destroys the pool for the current channel. Note: This is destructive and will delete all status information. You will need to re-run `pearbot setup` to rebuild the pool.'
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

      help do
        title 'pair'
        desc 'Pair up all active participants from the channel pool. Any currently snoozed partipants will not be included.'
      end

      def self.call(client, data, match)
        pool = Pool.find_by_channel_id_and_refresh(data.channel)

        if pool.blank?
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists ", gif: 'no')

        elsif pool.available_participants.empty?
          client.say(channel: data.channel, text: ":dusty_stick: Looks like nobody's available for pairing", gif: 'duster')

        elsif pool.available_participants.count == 1
          participant = pool.available_participants.first
          client.say(channel: data.channel, text: "<@#{participant.slack_user_id}> looks like you're on your own 😶", gif: 'alone')

        elsif round = ::RoundCreator.new(pool).create
          formatted_groupings = round.groupings.map(&:to_mentions).join("\n")

          client.say(
            channel: data.channel,
            text: "👯‍♀️The next round of pairs are:\n#{formatted_groupings}",
            gif: 'friendship'
          )
        end
      end
    end
    class Reminder < PearbotCommand
      command /reminder/
      command /who .*/

      help do
        title 'reminder / who did [someone] pair with'
        desc 'Print the results of the last draw.'
      end

      def self.call(client, data, match)
        pool = Pool.find_by_channel_id_and_refresh(data.channel)

        if pool.blank?
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists.", gif: 'no')
        elsif pool.rounds.any?
          formatted_groupings = pool.latest_round.groupings.map { |grouping| "> #{grouping.to_names}" }.join("\n")
          client.say(
            channel: data.channel,
            text: "🍐Last draw: #{format_date_time(pool.latest_round.created_at)}\n#{formatted_groupings}",
            gif: 'party'
          )
        else
          client.say(channel: data.channel, text: ":dusty_stick: You haven't ran any rounds in <##{data.channel}>", gif: 'duster')
        end
      end
    end
    class Snooze < PearbotCommand
      match /snooze <@?(\w+)>/

      help do
        title 'snooze [@user]'
        desc 'Temporarily disable drawing for either yourself or a given user from the pool.'
      end

      def self.call(client, data, match)
        user_id = replace_me_with_id(match[1], data.user)
        participant = Participant.find_by(slack_user_id: user_id)

        if !channel_message?(data.channel) && data.user != participant.slack_user_id
          client.say(channel: data.channel, text: "You can only snooze others in a group Pearbot channel")
          return
        end

        pool = participant.pools.last
        pool.refresh_participants if pool.present?

        if pool.blank?
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists ", gif: 'no')
        elsif participant.blank?
          client.say(channel: data.channel, text: "🙅‍♀️Can't find that user", gif: 'mystery')
        elsif !participant.in_pool?(pool)
          client.say(channel: data.channel, text: "🙅‍♀️#{participant.name} is not in the pool, ask them to join <##{data.channel}> first", gif: 'mystery')
        else
          participant.snooze_pool(pool)
          client.say(channel: data.channel, text: "Snoozed drawing for #{participant.name} in <##{pool.slack_channel_id}>. 😴", gif: 'sleep')
        end
      end
    end
    class Resume < PearbotCommand
      match /resume <@?(\w+)>/

      help do
        title 'resume @user'
        desc 'Re-enables drawing for either yourself or a given user from the pool.'
      end

      def self.call(client, data, match)
        user_id = replace_me_with_id(match[1], data.user)
        participant = Participant.find_by(slack_user_id: user_id)

        if !channel_message?(data.channel) && data.user != participant.slack_user_id
          client.say(channel: data.channel, text: "You can only resume others in a group Pearbot channel")
          return
        end

        pool = participant.pools.last
        pool.refresh_participants if pool.present?

        if pool.blank?
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists ", gif: 'no')
        elsif participant.blank?
          client.say(channel: data.channel, text: "🙅‍♀️Can't find that user", gif: 'mystery')
        elsif !participant.in_pool?(pool)
          client.say(channel: data.channel, text: "🙅‍♀️#{participant.name} is not in the pool, ask them to join <##{data.channel}> first", gif: 'mystery')
        else
          participant.resume_pool(pool)
          client.say(channel: data.channel, text: "Resumed drawing for #{participant.name} in <##{pool.slack_channel_id}>. 😊", gif: 'awake')
        end
      end
    end
  end
end
