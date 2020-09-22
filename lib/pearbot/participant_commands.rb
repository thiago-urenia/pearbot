module Pearbot
  module ParticipantCommands
    class Snooze < PearbotCommand
      match /snooze ?(me)/

      help do
        title 'snooze me/[@user]'
        desc 'Temporarily disable drawing for either yourself or a given user from the pool.'
      end

      def self.call(client, data, match)
        pool = Pool.find_by_channel_id_and_refresh(data.channel)
        user_id = replace_me_with_id(match[1], data.user)
        participant = Participant.find_by(slack_user_id: user_id)

        if pool.blank?
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists ", gif: 'no')
        elsif participant.blank?
          client.say(channel: data.channel, text: "🙅‍♀️Can't find that user", gif: 'mystery')
        elsif !participant.in_pool?(pool)
          client.say(channel: data.channel, text: "🙅‍♀️#{participant.name} is not in the pool, ask them to join <##{data.channel}> first", gif: 'mystery')
        else
          participant.snooze_pool(pool)
          client.say(channel: data.channel, text: "Snoozed drawing for #{participant.name} in <##{data.channel}>. 😴", gif: 'sleep')
        end
      end
    end

    class Resume < PearbotCommand
      match /resume ?(me)/

      help do
        title 'resume me/@user'
        desc 'Re-enables drawing for either yourself or a given user from the pool.'
      end

      def self.call(client, data, match)
        pool = Pool.find_by_channel_id_and_refresh(data.channel)
        user_id = replace_me_with_id(match[1], data.user)
        participant = Participant.find_by(slack_user_id: user_id)

        if pool.blank?
          client.say(channel: data.channel, text: "🙅‍♀️No pool for <##{data.channel}> exists ", gif: 'no')
        elsif participant.blank?
          client.say(channel: data.channel, text: "🙅‍♀️Can't find that user", gif: 'mystery')
        elsif !participant.in_pool?(pool)
          client.say(channel: data.channel, text: "🙅‍♀️#{participant.name} is not in the pool, ask them to join <##{data.channel}> first", gif: 'mystery')
        else
          participant.resume_pool(pool)
          client.say(channel: data.channel, text: "Resumed drawing for #{participant.name} in <##{data.channel}>. 😊", gif: 'awake')
        end
      end
    end
  end
end