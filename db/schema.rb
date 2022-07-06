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

ActiveRecord::Schema[7.0].define(version: 2022_07_05_234633) do
  create_table "addresses", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.string "address"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country"
    t.index ["organization_id"], name: "index_addresses_on_organization_id"
  end

  create_table "awards", force: :cascade do |t|
    t.integer "filing_id", null: false
    t.integer "receiver_id", null: false
    t.string "purpose"
    t.string "irs_section"
    t.bigint "cash_amount", default: 0, null: false
    t.bigint "non_cash_amount", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["filing_id"], name: "index_awards_on_filing_id"
    t.index ["receiver_id"], name: "index_awards_on_receiver_id"
  end

  create_table "filings", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.string "tax_period", null: false
    t.string "xml_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "tax_period"], name: "index_filings_on_organization_id_and_tax_period", unique: true
    t.index ["organization_id"], name: "index_filings_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "ein"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ein"], name: "index_organizations_on_ein", unique: true
  end

  add_foreign_key "awards", "organizations", column: "receiver_id"
end
