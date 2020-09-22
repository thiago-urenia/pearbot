module Pearbot
    module SharedCommands
      class PearbotCommand < SlackRubyBot::Commands::Base
        def self.replace_me_with_id(parsed_id, current_user_id)
          parsed_id == "me" ? current_user_id : parsed_id
        end

        def self.format_date_time(timestamp)
          unix = timestamp.to_i
          fallback = timestamp.strftime("%A, %B #{timestamp.day.ordinalize}, %Y at %H.%M UTC")

          "<!date^#{unix}^{date_long_pretty} at {time}|#{fallback}>"
        end
      end
      class Snooze < PearbotCommand
        match /snooze ?(me)/

        help do
          title 'snooze me'
          desc 'Temporarily disable drawing for yourself.'
        end

        def self.call(client, data, match)
          pool = Pool.last
          pool.refresh_participants if pool.present?
          participant = Participant.find_by(slack_user_id: data.user)

          if pool.blank?
            client.say(channel: data.channel, text: "🙅‍♀️ No pool exists ", gif: 'no')
          else
            participant.snooze_pool(pool)
            client.say(channel: data.channel, text: "Snoozed drawing for #{participant.name}. 😴", gif: 'sleep')
          end
        end
      end

      class Resume < PearbotCommand
        match /resume ?(me)/

        help do
          title 'resume me/@user'
          desc 'Re-enables drawing for yourself.'
        end

        def self.call(client, data, match)
          pool = Pool.last
          pool.refresh_participants if pool.present?
          participant = Participant.find_by(slack_user_id: data.user)

          if pool.blank?
            client.say(channel: data.channel, text: "🙅‍♀️ No pool exists ", gif: 'no')
          else
            participant.resume_pool(pool)
            client.say(channel: data.channel, text: "Resumed drawing for #{participant.name}. 😊", gif: 'awake')
          end
        end
      end
    end
  end
