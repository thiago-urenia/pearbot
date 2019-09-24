class RoundCreator
  # class RoundCreationsException < StandardError

  def initialize(pool)
    @pool = pool
  end

  def create
    @round = Round.create(pool: @pool)

    sliced_users.each { |users|  @round.pairings.create(users: users) }
  end

  private

  def sliced_users
    slice = randomised_users.each_slice(2).to_a
    if slice.last.size == 1
      slice.first << slice.pop
      slice.first.flatten!
    end
    slice
  end

  def randomised_users
    @rand ||= available_users.shuffle
  end

  def available_users
    @pool.available_users
  end
end
