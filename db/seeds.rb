# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

@pool = Pool.create(slack_channel_id: "Fabulous Channel")

11.times { PoolEntry.create(pool: @pool, participant: Participant.create(slack_user_id: SecureRandom.hex)) }
PoolEntry.create(pool: @pool, participant: Participant.create(slack_user_id: SecureRandom.hex), status: 'unavailable')

@round = Round.create(pool: @pool)
