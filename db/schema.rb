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

ActiveRecord::Schema.define(version: 20131020023539) do

  create_table "components", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "status",     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "components", ["user_id"], name: "index_components_on_user_id", using: :btree

  create_table "messages", force: true do |t|
    t.integer  "user_id"
    t.string   "text"
    t.integer  "status",     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_digest"
    t.boolean  "guest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "app_name"
    t.string   "subdomain"
  end

  add_index "users", ["subdomain"], name: "index_users_on_subdomain", unique: true, using: :btree

end
