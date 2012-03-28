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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120325203923) do

  create_table "ecard_orders", :force => true do |t|
    t.string   "code"
    t.integer  "ecard_id"
    t.boolean  "sent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
  end

  add_index "ecard_orders", ["ecard_id"], :name => "index_ecard_orders_on_ecard_id"

  create_table "ecards", :force => true do |t|
    t.string   "filename"
    t.integer  "variant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
    t.string   "title"
    t.float    "price"
    t.string   "video_file"
    t.string   "image"
  end

  create_table "senders", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "senders", ["email"], :name => "index_senders_on_email", :unique => true

  create_table "sent_ecards", :force => true do |t|
    t.string   "recipientemail"
    t.string   "recipientname"
    t.string   "message1"
    t.string   "message2"
    t.string   "nametoshow"
    t.string   "senderemail"
    t.integer  "ecard_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "securelink"
  end

end
