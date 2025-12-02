# app/serializers/contribution_serializer.rb
class ContributionSerializer
  include Typelizer::DSL

  attr_reader :contribution

  def initialize(contribution)
    @contribution = contribution
  end

  typelize :integer
  def id
    contribution.id
  end

  typelize :number
  def amount
    contribution.amount.to_f
  end

  typelize :string
  def status
    contribution.status
  end

  typelize :string
  def contributed_at
    contribution.contributed_at.iso8601
  end

  def contributor
    UserSerializer.new(contribution.contributor).as_json
  end

  def as_json
    {
      id: id,
      amount: amount,
      status: status,
      contributed_at: contributed_at,
      contributor: contributor
    }
  end
end