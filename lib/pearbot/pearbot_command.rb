module Pearbot
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
end
