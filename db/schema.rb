# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170327171325) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "credentials", force: true do |t|
    t.integer  "nation_id"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: true do |t|
    t.integer  "nation_id"
    t.integer  "eventNBID"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "time_zone"
    t.string   "sync_status",  default: "complete"
    t.integer  "sync_percent", default: 100
    t.datetime "sync_date"
  end

  create_table "nations", force: true do |t|
    t.string   "client_uid"
    t.string   "secret_key"
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "people", force: true do |t|
    t.integer  "nbid"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pic"
    t.integer  "nation_id"
    t.string   "mobile"
    t.string   "work_phone_number"
    t.string   "home_zip"
  end

  create_table "rsvps", force: true do |t|
    t.integer  "event_id"
    t.integer  "guests_count"
    t.boolean  "canceled"
    t.boolean  "attended"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rsvpNBID"
    t.integer  "nation_id"
    t.boolean  "volunteer"
    t.boolean  "is_private"
    t.string   "shift_ids",    default: [], array: true
    t.integer  "host_id"
    t.integer  "person_id"
  end

  create_table "users", force: true do |t|
    t.string   "email",                                          null: false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string   "activation_state"
    t.string   "activation_token"
    t.datetime "activation_token_expires_at"
    t.boolean  "active",                          default: true
  end

  add_index "users", ["activation_token"], name: "index_users_on_activation_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_me_token"], name: "index_users_on_remember_me_token", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree

end
