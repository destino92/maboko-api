# app/mailers/contribution_mailer.rb
class ContributionMailer < ApplicationMailer
  def notify_campaign_owner(contribution)
    @contribution = contribution
    @campaign = contribution.campaign
    @contributor = contribution.contributor

    mail(
      to: @campaign.creator.email_address,
      subject: "New contribution to your campaign: #{@campaign.title}"
    )
  end

  def notify_contributor(contribution)
    @contribution = contribution
    @campaign = contribution.campaign
    @contributor = contribution.contributor

    mail(
      to: @contributor.email_address,
      subject: "Thank you for your contribution to #{@campaign.title}"
    )
  end
end