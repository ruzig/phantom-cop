# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_01_05_040551) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bills", force: :cascade do |t|
    t.string "billing_cycle"
    t.boolean "on_free_trial"
    t.boolean "active", default: true
    t.datetime "free_trial_ends_on"
    t.datetime "next_billing_date"
    t.string "organization_billing_email"
    t.bigint "github_account_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["github_account_id"], name: "index_bills_on_github_account_id"
  end

  create_table "github_accounts", force: :cascade do |t|
    t.string "login"
    t.integer "github_id"
    t.string "node_id"
    t.string "avatar_url"
    t.string "html_url"
    t.string "account_type"
    t.integer "installation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["github_id"], name: "index_github_accounts_on_github_id"
  end

  create_table "github_pull_requests", force: :cascade do |t|
    t.integer "pull_request_number"
    t.integer "reponsitory_github_id"
    t.text "filenames", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "repositories", force: :cascade do |t|
    t.integer "github_id"
    t.string "node_id"
    t.string "name"
    t.string "full_name"
    t.boolean "private"
    t.bigint "github_account_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "sentry_project_id"
    t.index ["github_account_id"], name: "index_repositories_on_github_account_id"
    t.index ["github_id"], name: "index_repositories_on_github_id"
  end

  create_table "sentry_events", force: :cascade do |t|
    t.string "event_id"
    t.uuid "installation_id"
    t.string "project_id"
    t.text "filename"
    t.integer "line_number"
    t.integer "column_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "events_counter"
    t.index ["installation_id"], name: "index_sentry_events_on_installation_id"
    t.index ["project_id"], name: "index_sentry_events_on_project_id"
  end

  create_table "sentry_installations", force: :cascade do |t|
    t.string "organization_slug"
    t.string "refresh_token"
    t.uuid "installation_id"
    t.json "external_data"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "token"
    t.datetime "token_expired_at"
    t.index ["installation_id"], name: "index_sentry_installations_on_installation_id"
  end

  create_table "sentry_projects", force: :cascade do |t|
    t.string "project_id"
    t.string "project_slug"
    t.uuid "installation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["installation_id"], name: "index_sentry_projects_on_installation_id"
  end

end
