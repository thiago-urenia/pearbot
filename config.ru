# This file is used by Rack-based servers to start the application.
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'dotenv'
require_relative 'config/environment'

Dotenv.load

Thread.abort_on_exception = true
Thread.new do
  Pearbot::Bot.run
end

run Rails.application
