module Pearbot
  module ParticipantCommands

    class Exclude < PearbotCommand
      match /exclude <@?(\w+)>/

      def self.call(client, data, match)
        conversation = self.conversation(data.channel)
        sender = Participant.find_or_initialize_by(slack_user_id: data.user)

        matched_user_id = match[1]
        matched_participant = Participant.find_or_initialize_by(slack_user_id: matched_user_id)

        if !conversation.is_direct_message?
          self.reply_in_thread(client, data, text: "🙅‍♀️Speak to @pearbot directly to manage your exclusions")
          return
        end

        if matched_participant == sender
          self.reply_in_thread(client, data, text: "Soz, You can't exclude yourself!")
        elsif sender.excluded_participants.include?(matched_participant)
          self.reply_in_thread(client, data, text: "#{matched_participant.name} is already in your exclusions")
        elsif Exclusion.create(excluder: sender, excluded_participant: matched_participant)
          self.reply_in_thread(client, data, text: "🤫 Successfully excluded *#{matched_participant.name}* from future pairings. \n > You can include them at any time by DM-ing me `include [@name]`", gif: "blocked")
        end

        self.reply_in_thread(client, data, text: "Your current list of exclusions are: #{sender.exclusions_list}")

      rescue Slack::Web::Api::Errors::UserNotFound
        self.reply_in_thread(client, data, text: "🙅‍♀️Can't find user #{user_id}", gif: 'mystery')
      end
    end

    class Include < PearbotCommand
      match /include <@?(\w+)>/

      def self.call(client, data, match)
        conversation = self.conversation(data.channel)
        sender = Participant.find_or_initialize_by(slack_user_id: data.user)

        matched_user_id = match[1]
        matched_participant = Participant.find_or_initialize_by(slack_user_id: matched_user_id)

        if !conversation.is_direct_message?
          self.reply_in_thread(client, data, text: "🙅‍♀️Speak to @pearbot directly to manage your exclusions")
          return
        end

        exclusion = sender.exclusions.find_by(excluded_participant: matched_participant)

        if matched_participant == sender
          self.reply_in_thread(client, data, text: "Soz, You can't be paired with yourself!")
        elsif exclusion&.destroy
          self.reply_in_thread(client, data, text: "🤫 Successfully included *#{matched_participant.name}* for future pairings.", gif: "allow")
        end

        self.reply_in_thread(client, data, text: "Your current list of exclusions are: #{sender.exclusions_list}")

      rescue Slack::Web::Api::Errors::UserNotFound
        self.reply_in_thread(client, data, text: "🙅‍♀️Can't find user #{user_id}", gif: 'mystery')
      end
    end
  end
end
