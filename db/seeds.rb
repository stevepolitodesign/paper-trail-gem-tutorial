# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

@article = Article.create(title: "Version 1", body: Faker::Lorem.paragraph)
2.upto(6) do |i|
  @article = Article.update(title: "Version #{i}")
end

@deleted_article = Article.create(title: "Deleted Article", body: Faker::Lorem.paragraph)
@deleted_article.destroy
