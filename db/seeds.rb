# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
# This file seeds the database with sample data for development

puts "🌱 Starting database seeding..."

# ============================================================================
# Clear existing data (careful in production!)
# ============================================================================

if Rails.env.development?
  puts "🗑️  Clearing existing data..."
  
  CampaignComment.destroy_all
  Subscription.destroy_all
  PayoutRequest.destroy_all
  Contribution.destroy_all
  CampaignView.destroy_all
  Campaign.destroy_all
  Category.destroy_all
  Session.destroy_all
  User.destroy_all
  
  puts "✅ Data cleared"
end

# ============================================================================
# Create Categories
# ============================================================================

puts "\n📂 Creating categories..."

categories_data = [
  { name: "Medical", slug: "medical" },
  { name: "Education", slug: "education" },
  { name: "Community", slug: "community" },
  { name: "Emergency", slug: "emergency" },
  { name: "Wedding", slug: "wedding" },
  { name: "Business", slug: "business" },
  { name: "Events", slug: "events" },
  { name: "Other", slug: "other" }
]

categories = categories_data.map do |cat_data|
  Category.create!(cat_data)
end

puts "✅ Created #{categories.count} categories"

# ============================================================================
# Create Users
# ============================================================================

puts "\n👥 Creating users..."

# Create admin user
admin = User.create!(
  email_address: "admin@crowdshare.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Admin",
  last_name: "User",
  phone_number: "+243770000000",
  date_of_birth: Date.new(1990, 1, 1),
  sex: "other"
)

puts "✅ Created admin user: #{admin.email_address}"

# Create regular users
users = []
15.times do |i|
  user = User.create!(
    email_address: "user#{i + 1}@example.com",
    password: "password123",
    password_confirmation: "password123",
    first_name: ["John", "Jane", "Alice", "Bob", "Charlie", "Diana", "Eve", "Frank"].sample,
    last_name: ["Doe", "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia"].sample,
    phone_number: "+24377#{7000000 + i}",
    date_of_birth: Date.new(1980 + rand(30), rand(1..12), rand(1..28)),
    sex: ["male", "female", "other"].sample
  )
  users << user
end

puts "✅ Created #{users.count} regular users"

# ============================================================================
# Create Campaigns
# ============================================================================

puts "\n📢 Creating campaigns..."

campaign_titles = [
  "Help Fund Medical Treatment for My Mother",
  "Support Local School Computer Lab",
  "Emergency Relief for Flood Victims",
  "Start a Community Garden Project",
  "Wedding Fund for John and Jane",
  "Launch Sustainable Fashion Business",
  "Organize Youth Sports Tournament",
  "Rebuild After Fire Disaster",
  "Fund University Tuition Fees",
  "Community Clean Water Project"
]

campaigns = []
30.times do |i|
  creator = [admin, *users].sample
  category = categories.sample

  # Add end_date (30-90 days from now)
  start_date = Time.current

  # Add end_date (30-90 days from now)
  end_date = rand(30..90).days.from_now
  
  campaign = Campaign.create!(
    creator: creator,
    category: category,
    title: campaign_titles.sample + " ##{i + 1}",
    description: [
      "# Campaign Description\n\n",
      "This is an important campaign that needs your support. ",
      "Every contribution makes a difference and helps us reach our goal.\n\n",
      "## Why This Matters\n\n",
      "Your support will directly impact lives and create positive change in our community. ",
      "We are committed to transparency and will provide regular updates on our progress.\n\n",
      "## How Funds Will Be Used\n\n",
      "- 60% for direct expenses\n",
      "- 25% for operational costs\n",
      "- 15% for contingency\n\n",
      "Thank you for your generosity!"
    ].join,
    goal_amount: [500, 1000, 2500, 5000, 10000, 25000, 50000].sample,
    status: ["active", "active", "active", "completed", "draft"].sample,
    current_amount: 0,
    start_date: start_date,
    end_date: end_date
  )
  
  campaigns << campaign
end

puts "✅ Created #{campaigns.count} campaigns"

# ============================================================================
# Create Contributions
# ============================================================================

puts "\n💰 Creating contributions..."

contribution_count = 0

campaigns.select(&:active?).each do |campaign|
  # Each active campaign gets 5-20 contributions
  num_contributions = rand(5..20)
  
  num_contributions.times do
    contributor = users.sample
    amount = [25, 50, 100, 250, 500, 1000, 2500].sample
    
    contribution = campaign.contributions.create!(
      contributor: contributor,
      amount: amount,
      status: "succeeded",
      payment_reference: "seed_#{SecureRandom.hex(8)}",
      contributed_at: rand(30.days.ago..Time.current)
    )
    
    contribution_count += 1
  end
end

puts "✅ Created #{contribution_count} contributions"

# ============================================================================
# Create Campaign Views
# ============================================================================

puts "\n👀 Creating campaign views..."

view_count = 0

campaigns.each do |campaign|
  # Each campaign gets 20-150 views
  num_views = rand(20..150)
  
  num_views.times do
    campaign.campaign_views.create!(
      viewed_at: rand(30.days.ago..Time.current)
    )
    view_count += 1
  end
end

puts "✅ Created #{view_count} campaign views"

# ============================================================================
# Create Subscriptions
# ============================================================================

puts "\n🔔 Creating subscriptions..."

subscription_count = 0

campaigns.select(&:active?).each do |campaign|
  # Each campaign gets 2-8 subscribers
  num_subscribers = rand(2..8)
  
  users.sample(num_subscribers).each do |subscriber|
    begin
      campaign.subscriptions.create!(
        user: subscriber,
        subscribed_at: rand(30.days.ago..Time.current)
      )
      subscription_count += 1
    rescue ActiveRecord::RecordInvalid
      # Skip if user already subscribed
    end
  end
end

puts "✅ Created #{subscription_count} subscriptions"

# ============================================================================
# Create Comments
# ============================================================================

puts "\n💬 Creating comments..."

comment_count = 0

campaigns.select(&:active?).sample(10).each do |campaign|
  # Campaign creator posts an update
  campaign.campaign_comments.create!(
    user: campaign.creator,
    content: "Thank you all for your amazing support! We've made great progress and are getting closer to our goal every day. Your contributions are truly making a difference. 🙏",
    comment_type: :campaign_update
  )
  comment_count += 1
  
  # Random users post comments
  rand(2..5).times do
    campaign.campaign_comments.create!(
      user: users.sample,
      content: [
        "This is such an important cause. Happy to contribute!",
        "Great initiative! Wishing you all the best.",
        "Just donated. Hope you reach your goal soon!",
        "Shared with my friends. Good luck!",
        "Proud to support this campaign!"
      ].sample,
      comment_type: "comment"
    )
    comment_count += 1
  end
end

puts "✅ Created #{comment_count} comments"

# ============================================================================
# Summary
# ============================================================================

puts "\n" + "=" * 60
puts "🎉 DATABASE SEEDING COMPLETE!"
puts "=" * 60
puts "\n📊 Summary:"
puts "  • #{User.count} users"
puts "  • #{Category.count} categories"
puts "  • #{Campaign.count} campaigns"
puts "  • #{Contribution.count} contributions"
puts "  • #{CampaignView.count} campaign views"
puts "  • #{Subscription.count} subscriptions"
puts "  • #{CampaignComment.count} comments/updates"
puts "\n🔑 Test Credentials:"
puts "  Email: admin@crowdshare.com"
puts "  Password: password123"
puts "\n  Or use: user1@example.com (user2, user3, etc.)"
puts "  Password: password123"
puts "\n" + "=" * 60