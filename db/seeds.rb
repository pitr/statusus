# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Plan.where(name: 'basic').first_or_create!(price: 0, description: 'Free basic plan', active: true)
Plan.where(name: 'premium').first_or_create!(price: 499, description: 'Premium plan', active: true)

Plan.where(name: 'test').first_or_create!(price: 0, description: 'Test plan', active: true)
Plan.where(name: 'foo').first_or_create!(price: 0, description: 'Test foo plan', active: true)
