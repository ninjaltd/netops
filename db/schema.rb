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

ActiveRecord::Schema[8.1].define(version: 2026_09_17_012316) do
  create_table "network_hosts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "design_name"
    t.string "hostname", null: false
    t.string "ip_address"
    t.string "location"
    t.string "mac_address"
    t.string "model"
    t.text "notes"
    t.integer "role", default: 6, null: false
    t.string "serial_number"
    t.integer "status", default: 0, null: false
    t.string "subnet"
    t.datetime "updated_at", null: false
    t.string "vendor"
    t.integer "vlan_id"
    t.index ["hostname"], name: "index_network_hosts_on_hostname", unique: true
    t.index ["location"], name: "index_network_hosts_on_location"
    t.index ["role"], name: "index_network_hosts_on_role"
    t.index ["status"], name: "index_network_hosts_on_status"
    t.index ["vendor"], name: "index_network_hosts_on_vendor"
  end
end
