# app/serializers/category_serializer.rb
class CategorySerializer
  include Typelizer::DSL

  attr_reader :category

  def initialize(category)
    @category = category
  end

  typelize :integer
  def id
    category.id
  end

  typelize :string
  def name
    category.name
  end

  typelize :string
  def slug
    category.slug
  end

  def as_json
    {
      id: id,
      name: name,
      slug: slug
    }
  end
end