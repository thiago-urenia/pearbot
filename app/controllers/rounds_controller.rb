class RoundsController < ApplicationController
  def create
    RoundCreator.new(Pool.last)
  end
end
