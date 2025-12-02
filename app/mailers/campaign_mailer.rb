# app/mailers/campaign_mailer.rb
class CampaignMailer < ApplicationMailer
  def campaign_update(subscriber, campaign)
    @subscriber = subscriber
    @campaign = campaign

    mail(
      to: @subscriber.email_address,
      subject: "Update on campaign: #{@campaign.title}"
    )
  end

  def goal_reached(campaign)
    @campaign = campaign

    mail(
      to: @campaign.creator.email_address,
      subject: "Congratulations! Your campaign goal has been reached!"
    )
  end
end