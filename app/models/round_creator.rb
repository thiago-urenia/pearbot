class RoundCreator
  # class RoundCreationsException < StandardError

  def initialize(pool)
    @pool = pool
  end

  def create
    @round = Round.create(pool: @pool)

    sliced_participants.reverse.each { |participants|  @round.groupings.create(participants: participants) }
    @round
  end

  private

  def sliced_participants
    slice = randomised_participants.each_slice(2).to_a
    if slice.last.size == 1
      slice.first << slice.pop
      slice.first.flatten!
    end
    slice
  end

  def randomised_participants
    @rand ||= available_participants.shuffle
  end

  def available_participants
    @pool.available_participants
  end
end
