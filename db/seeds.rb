# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
@pool = FactoryBot.create(:pool)

11.times { FactoryBot.create(:pool_entry, :available, pool: @pool) }
FactoryBot.create(:pool_entry, :snoozed, pool: @pool)

@round = FactoryBot.create(:round)
