module Pearbot
  class Bot < SlackRubyBot::Bot
    require_relative 'commands.rb'
  end
end
