# app/serializers/payout_request_serializer.rb
class PayoutRequestSerializer
  include Typelizer::DSL

  attr_reader :payout_request

  def initialize(payout_request)
    @payout_request = payout_request
  end

  typelize :integer
  def id
    payout_request.id
  end

  typelize :number
  def amount
    payout_request.amount.to_f
  end

  typelize :string
  def status
    payout_request.status
  end

  typelize :string, null: true
  def disbursement_reference
    payout_request.disbursement_reference
  end

  typelize :string
  def requested_at
    payout_request.requested_at.iso8601
  end

  def as_json
    {
      id: id,
      amount: amount,
      status: status,
      disbursement_reference: disbursement_reference,
      requested_at: requested_at
    }
  end
end