# app/mailers/payout_mailer.rb
class PayoutMailer < ApplicationMailer
  def payout_completed(payout_request)
    @payout_request = payout_request
    @campaign = payout_request.campaign

    mail(
      to: payout_request.requestor.email_address,
      subject: "Payout completed for #{@campaign.title}"
    )
  end

  def payout_failed(payout_request)
    @payout_request = payout_request
    @campaign = payout_request.campaign

    mail(
      to: payout_request.requestor.email_address,
      subject: "Payout failed for #{@campaign.title}"
    )
  end
end