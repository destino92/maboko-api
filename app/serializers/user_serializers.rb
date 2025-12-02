# app/serializers/user_serializer.rb
class UserSerializer
  include Typelizer::DSL

  attr_reader :user

  def initialize(user)
    @user = user
  end

  typelize :integer
  def id
    user.id
  end

  typelize :string
  def email_address
    user.email_address
  end

  typelize :string
  def first_name
    user.first_name
  end

  typelize :string
  def last_name
    user.last_name
  end

  typelize :string
  def full_name
    user.full_name
  end

  typelize :string
  def phone_number
    user.phone_number
  end

  def as_json
    {
      id: id,
      email_address: email_address,
      first_name: first_name,
      last_name: last_name,
      full_name: full_name,
      phone_number: phone_number
    }
  end
end