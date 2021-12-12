# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Category.create(name:'沖縄')
Place.create(name:'那覇市',category_id:'1')
Place.create(name:'浦添市',category_id:'2')
Place.create(name:'宜野湾市',category_id:'3')
