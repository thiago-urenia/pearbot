module Pearbot
  module PoolCommands

    class Hello < PearbotCommand
      command /hi/
      command /hello/

      help do
        title 'Hello'
        desc 'Say hello to Pearbot'
      end
      def self.call(client, data, match)
        conversation = self.conversation(data.channel)
        pool = ::Pool.find_by(slack_channel_id: data.channel)

        if conversation.is_channel? && pool.nil?
          message = "Hello <##{data.channel}> \n\n"
          message += "Did you want my help to set up automatic pairings? If so, just type `@pearbot setup` to get started."
        else
          message = "Hello there <@#{data.user}>"
        end

        client.say(channel: data.channel, text: message, gif: "hello")
      end
    end

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
          message = "✨ Okay, I set up <##{data.channel}> for pairings, with #{pool.participants.count} participants.\n>\n>"
          message += "You can set up regular pairing rounds using slack reminders, like so:\n>"
          message += "`/remind <##{data.channel}>  “@pearbot pair” every 2 weeks`\n>\n>"
          message += "Try `/remind help` if you get stuck."
          client.say(channel: data.channel, text: message, gif: 'hello')

        else
          client.say(channel: data.channel, text: "🤭 I've already created the pairing pool for <##{data.channel}>.")
        end
      end
    end

    class Refresh < PearbotCommand
      command /refresh/

      help do
        title 'refresh'
        desc 'Refresh the pairing pool so it matches the current members of the channel. You should run this regularly to clean up the pairing pool. Note this will only remove users who have left the channel from the pairing pool, snoozed users will remain in the pairing pool unless they leave the channel.'
      end

      def self.call(client, data, match)
        pool = ::Pool.new(slack_channel_id: data.channel)

        if pool.present?
          pool.refresh_participants
          message = "♻️ I refreshed the pairing pool for <##{data.channel}>."
          message += "\nThere are now #{pool.reload.participants.count} participants"
          message += "\n> #{Participant.name_list(pool.participants)}" if pool.participants.any?
          client.say(channel: data.channel, text: message)
        else
          client.say(channel: data.channel, text: "🚨 I couldn't find a pairing pool for <##{data.channel}>. You may need to run `@pearbot setup` first.")
        end
      end
    end
    class Status < PearbotCommand
      command /status/

      help do
        title 'status'
        desc 'Display status information about the participants of a pairing pool and when they were last drawn.'
      end

      def self.call(client, data, match)
        pool = Pool.find_by_channel_id_and_refresh(data.channel)

        if pool.blank?
          client.say(channel: data.channel, text: "🚨 I couldn't find a pairing pool for <##{data.channel}>. You may need to run `@pearbot setup` first.")
        else
          summary = ":janet: I found #{pool.reload.participants.count} participants in the <##{data.channel}> pool"
          summary += "\n> 👋 *Available*: #{pool.list_available_participants}" if pool.available_participants.any?
          summary += "\n> 🛌 *Snoozed*: #{pool.list_snoozed_participants}" if pool.snoozed_participants.any?
          summary += "\n🍐 Last draw: #{format_date_time(pool.latest_round.created_at)}" if pool.rounds.any?

          client.say(channel: data.channel, text: summary)
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
          client.say(channel: data.channel, text: "💣 I destroyed the pairing pool for <##{data.channel}>", gif: 'bye')
        else
          client.say(channel: data.channel, text: "🚨 I couldn't find a pairing pool for <##{data.channel}>. You may need to run `@pearbot setup` first.")
        end
      end
    end
    class Pair < PearbotCommand
      command /pair/

      help do
        title 'pair'
        desc 'Pair up all active participants from the channel pairing pool. Any currently snoozed partipants will not be included.'
      end

      def self.call(client, data, match)
        pool = Pool.find_by_channel_id_and_refresh(data.channel)

        if pool.blank?
          client.say(channel: data.channel, text: "🚨 I couldn't find a pairing pool for <##{data.channel}>. You may need to run `@pearbot setup` first.")

        elsif pool.available_participants.empty?
          client.say(channel: data.channel, text: "🚨 There's noone here! I can't make pairs out of nothing. :dusty_stick:")

        elsif pool.available_participants.count == 1
          participant = pool.available_participants.first
          client.say(channel: data.channel, text: "I'd love to pair you with someone, <@#{participant.slack_user_id}>, but it looks like you're on your own.", gif: 'alone')

        elsif round = ::RoundCreator.new(pool).create
          groupings = round.groupings
          groupings.map(&:send_intro)

          client.say(
            channel: data.channel,
            text: "👯‍♀️ I just introduced #{ActionController::Base.helpers.pluralize(groupings.count, 'new pair')} to each other, check your DMs folks!"
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
          client.say(channel: data.channel, text: "🚨 I couldn't find a pairing pool for <##{data.channel}>. You may need to run `@pearbot setup` first.")
        elsif pool.rounds.any?
          formatted_groupings = pool.latest_round.groupings.map { |grouping| "> #{grouping.to_names}" }.join("\n")
          client.say(
            channel: data.channel,
            text: "🍐Last draw: #{format_date_time(pool.latest_round.created_at)}\n#{formatted_groupings}",
            gif: 'party'
          )
        else
          client.say(channel: data.channel, text: "🚨 Uh-oh, you need to run a pairing round in <##{data.channel}> first. :dusty_stick: Try `@pearbot pair` to kick one off.")
        end
      end
    end
    class Snooze < PearbotCommand
      match /snooze <@?(\w+)>/
      match /snooze ?(me)/

      help do
        title 'snooze [@user]'
        desc 'Temporarily disable drawing for either yourself or a given user from the pairing pool.'
      end

      def self.call(client, data, match)
        user_id = replace_me_with_id(match[1], data.user)
        participant = Participant.find_by(slack_user_id: user_id)

        conversation = self.conversation(data.channel)

        if !conversation.is_channel? && data.user != participant.slack_user_id
          client.say(channel: data.channel, text: ":point_up: Manage your own snooze status in your DMs with @pearbot. You can still snooze/resume others in the channel.")
          return
        end

        if conversation.is_channel?
          pool = Pool.find_by_channel_id_and_refresh(data.channel)
        end

        if pool.blank?
          client.say(channel: data.channel, text: "🚨 I couldn't find a pairing pool for <##{data.channel}>. You may need to run `@pearbot setup` first.")
        elsif participant.blank?
          client.say(channel: data.channel, text: "🚨 I couldn't find #{participant.name}'s user'.", gif: 'mystery')
        elsif !participant.in_pool?(pool)
          client.say(channel: data.channel, text: "🚨 #{participant.name} is not in the channel, ask them to join <##{data.channel}> first.", gif: 'mystery')
        else
          participant.snooze_pool(pool)
          client.say(channel: data.channel, text: "⏸ Snoozed pairings for #{participant.name} in <##{pool.slack_channel_id}>.", gif: "sleep")

          sender = Participant.find_by(slack_user_id: data.user)

          if sender != participant
            Pearbot::SlackApi::Conversation.open_conversation_for([participant]).send_message("#{sender.name} snoozed you in <##{data.channel}>")
          end
        end
      end
    end
    class Resume < PearbotCommand
      match /resume <@?(\w+)>/
      match /resume ?(me)/

      help do
        title 'resume @user'
        desc 'Re-enables drawing for either yourself or a given user from the pairing pool.'
      end

      def self.call(client, data, match)
        user_id = replace_me_with_id(match[1], data.user)
        participant = Participant.find_by(slack_user_id: user_id)

        conversation = self.conversation(data.channel)

        if !conversation.is_channel? && data.user != participant&.slack_user_id
          client.say(channel: data.channel, text: ":point_up: Manage your own snooze status in your DMs with @pearbot. You can still snooze/resume others in the channel.")
          return
        end

        if conversation.is_channel?
          pool = Pool.find_by_channel_id_and_refresh(data.channel)
        end

        if pool.blank?
          client.say(channel: data.channel, text: "🚨 I couldn't find a pairing pool for <##{data.channel}>. You may need to run `@pearbot setup` first.")
        elsif participant.blank?
          client.say(channel: data.channel, text: "🚨 I couldn't find #{participant.name}'s user'.", gif: 'mystery')
        elsif !participant.in_pool?(pool)
          client.say(channel: data.channel, text: "🚨 #{participant.name} is not in the channel, ask them to join <##{data.channel}> first", gif: 'mystery')
        else
          participant.resume_pool(pool)
          client.say(channel: data.channel, text: "⏩ Resumed pairings for #{participant.name} in <##{pool.slack_channel_id}>.", gif: 'awake')

          sender = Participant.find_by(slack_user_id: data.user)

          if sender != participant
            Pearbot::SlackApi::Conversation.open_conversation_for([participant]).send_message("#{sender.name} resumed you in <##{data.channel}>")
          end
        end
      end
    end
  end
end
