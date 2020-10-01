module Pearbot
  module ParticipantCommands

    # class Exclude < PearbotCommand
    #   match /exclude <@?(\w+)>/

    #   def self.call(client, data, match)
    #     conversation = self.conversation(data.channel)
    #     sender = Participant.find_or_initialize_by(slack_user_id: data.user)

    #     matched_user_id = match[1]
    #     matched_participant = Participant.find_or_initialize_by(slack_user_id: matched_user_id)

    #     if !conversation.is_direct_message?
    #       self.reply_in_thread(client, data, text: "🚨 DM <@pearbot> privately to manage your exclusions.")
    #       return
    #     end

    #     if matched_participant == sender
    #       self.reply_in_thread(client, data, text: "🚨 Soz, You can't exclude yourself!")
    #     elsif sender.excluded_participants.include?(matched_participant)
    #       self.reply_in_thread(client, data, text: ":point_up: #{matched_participant.name} is already in your exclusions")
    #     elsif Exclusion.create(excluder: sender, excluded_participant: matched_participant)
    #       self.reply_in_thread(client, data, text: "🤫 You won't be paired with #{matched_participant.name} in future rounds. \n  _Tip: You can include them at any time by DM-ing me `include [@name]`_")
    #     end

    #     self.reply_in_thread(client, data, text: "🍐 Here's everyone you won't be paired with: #{sender.exclusions_list}")

    #   rescue Slack::Web::Api::Errors::UserNotFound
    #     self.reply_in_thread(client, data, text: "🚨 Can't find user #{user_id}", gif: 'mystery')
    #   end
    # end

    # class Include < PearbotCommand
    #   match /include <@?(\w+)>/

    #   def self.call(client, data, match)
    #     conversation = self.conversation(data.channel)
    #     sender = Participant.find_or_initialize_by(slack_user_id: data.user)

    #     matched_user_id = match[1]
    #     matched_participant = Participant.find_or_initialize_by(slack_user_id: matched_user_id)

    #     if !conversation.is_direct_message?
    #       self.reply_in_thread(client, data, text: "🚨 DM <@pearbot> privately to manage your exclusions.")
    #       return
    #     end

    #     exclusion = sender.exclusions.find_by(excluded_participant: matched_participant)

    #     if matched_participant == sender
    #       self.reply_in_thread(client, data, text: "Soz, You can't be paired with yourself!")
    #     elsif exclusion&.destroy
    #       self.reply_in_thread(client, data, text: "🤫 You can now be paired with *#{matched_participant.name}* in future rounds.")
    #     end

    #     self.reply_in_thread(client, data, text: "🍐 Here's everyone you won't be paired with: #{sender.exclusions_list}")

    #   rescue Slack::Web::Api::Errors::UserNotFound
    #     self.reply_in_thread(client, data, text: "🚨 Can't find user #{user_id}", gif: 'mystery')
    #   end
    # end

    class Snooze < PearbotCommand
      match /snooze all/

      help do
        title 'snooze all'
        desc '[Available in DMs with Pearbot only] Temporarily disable drawing for yourself in all Pearbot channels you belong to.'
      end

      def self.call(client, data, match)
        participant = Participant.find_by(slack_user_id: data.user)
        pools = participant.pools

        conversation = self.conversation(data.channel)

        if !conversation.is_direct_message?
          self.reply_in_thread(client, data, text: "🚨 Speak to <@pearbot> directly to use this command.")
          return
        end

        if pools.empty?
          client.say(channel: data.channel, text: "🚨 You don't belong to any pools.")
        else
          pools.each do |pool|
            participant.snooze_pool(pool)
          end

          pool_tags = pools.map { |pool| "<##{pool.slack_channel_id}>" }.join(', ')

          client.say(channel: data.channel, text: "⏸ You've been temporarily snoozed in #{pool_tags}>.", gif: "sleep")
        end
      end
    end

    class Resume < PearbotCommand
      match /resume all/

      help do
        title 'resume all'
        desc '[Available in DMs with Pearbot only] Re-enables drawing for yourself in all Pearbot channels you belong to.'
      end

      def self.call(client, data, match)
        participant = Participant.find_by(slack_user_id: data.user)
        pools = participant.pools

        conversation = self.conversation(data.channel)

        if !conversation.is_direct_message?
          self.reply_in_thread(client, data, text: "🚨 Speak to <@pearbot> directly to use this command.")
          return
        end

        if pools.empty?
          client.say(channel: data.channel, text: "🚨 You don't belong to any pools.")
        else
          pools.each do |pool|
            participant.resume_pool(pool)
          end
        end

        pool_tags = pools.map { |pool| "<##{pool.slack_channel_id}>" }.join(', ')

        client.say(channel: data.channel, text: "⏩ Resumed drawing in #{pool_tags}>.", gif: "awake")
      end
    end
  end
end
