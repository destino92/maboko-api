# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_02_152454) do
  create_schema "extensions"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.uuid-ossp"
  enable_extension "graphql.pg_graphql"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"
  enable_extension "vault.supabase_vault"

  create_table "public.action_text_rich_texts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "public.active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "public.active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "public.active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "public.campaign_comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "campaign_id", null: false
    t.string "comment_type", default: "comment", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["campaign_id", "created_at"], name: "index_campaign_comments_on_campaign_id_and_created_at"
    t.index ["campaign_id"], name: "index_campaign_comments_on_campaign_id"
    t.index ["comment_type"], name: "index_campaign_comments_on_comment_type"
    t.index ["user_id"], name: "index_campaign_comments_on_user_id"
  end

  create_table "public.campaign_views", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "campaign_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "viewed_at", null: false
    t.index ["campaign_id", "viewed_at"], name: "index_campaign_views_on_campaign_id_and_viewed_at"
    t.index ["campaign_id"], name: "index_campaign_views_on_campaign_id"
    t.index ["viewed_at"], name: "index_campaign_views_on_viewed_at"
  end

  create_table "public.campaigns", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "category_id", null: false
    t.datetime "created_at", null: false
    t.uuid "creator_id", null: false
    t.integer "current_amount", default: 0, null: false
    t.date "end_date", null: false
    t.integer "goal_amount", null: false
    t.date "start_date", null: false
    t.string "status", default: "active", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "view_count", default: 0, null: false
    t.index ["category_id"], name: "index_campaigns_on_category_id"
    t.index ["created_at"], name: "index_campaigns_on_created_at"
    t.index ["creator_id", "status"], name: "index_campaigns_on_creator_id_and_status"
    t.index ["creator_id"], name: "index_campaigns_on_creator_id"
    t.index ["current_amount"], name: "index_campaigns_on_current_amount"
    t.index ["status"], name: "index_campaigns_on_status"
  end

  create_table "public.categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "public.contributions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount"
    t.uuid "campaign_id", null: false
    t.datetime "contributed_at", null: false
    t.uuid "contributor_id", null: false
    t.datetime "created_at", null: false
    t.string "payment_reference"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "status"], name: "index_contributions_on_campaign_id_and_status"
    t.index ["campaign_id"], name: "index_contributions_on_campaign_id"
    t.index ["contributed_at"], name: "index_contributions_on_contributed_at"
    t.index ["contributor_id"], name: "index_contributions_on_contributor_id"
    t.index ["payment_reference"], name: "index_contributions_on_payment_reference", unique: true
    t.index ["status"], name: "index_contributions_on_status"
  end

  create_table "public.payout_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount", null: false
    t.uuid "campaign_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "disbursement_reference"
    t.datetime "processed_at"
    t.datetime "requested_at", null: false
    t.uuid "requestor_id", null: false
    t.string "status", default: "requested", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "status"], name: "index_payout_requests_on_campaign_id_and_status"
    t.index ["campaign_id"], name: "index_payout_requests_on_campaign_id"
    t.index ["requestor_id"], name: "index_payout_requests_on_requestor_id"
    t.index ["status"], name: "index_payout_requests_on_status"
  end

  create_table "public.sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.string "token"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id", null: false
    t.index ["token"], name: "index_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "public.subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "campaign_id", null: false
    t.datetime "created_at", null: false
    t.datetime "subscribed_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["campaign_id", "user_id"], name: "index_subscriptions_on_campaign_id_and_user_id", unique: true
    t.index ["campaign_id"], name: "index_subscriptions_on_campaign_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "public.users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "email_address", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest", null: false
    t.string "phone_number"
    t.string "sex"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
  end

  add_foreign_key "public.active_storage_attachments", "public.active_storage_blobs", column: "blob_id"
  add_foreign_key "public.active_storage_variant_records", "public.active_storage_blobs", column: "blob_id"
  add_foreign_key "public.campaign_comments", "public.campaigns"
  add_foreign_key "public.campaign_comments", "public.users"
  add_foreign_key "public.campaign_views", "public.campaigns"
  add_foreign_key "public.campaigns", "public.categories"
  add_foreign_key "public.campaigns", "public.users", column: "creator_id"
  add_foreign_key "public.contributions", "public.campaigns"
  add_foreign_key "public.contributions", "public.users", column: "contributor_id"
  add_foreign_key "public.payout_requests", "public.campaigns"
  add_foreign_key "public.payout_requests", "public.users", column: "requestor_id"
  add_foreign_key "public.sessions", "public.users"
  add_foreign_key "public.subscriptions", "public.campaigns"
  add_foreign_key "public.subscriptions", "public.users"

end
