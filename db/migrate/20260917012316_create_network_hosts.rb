class CreateNetworkHosts < ActiveRecord::Migration[8.1]
  def change
    create_table :network_hosts do |t|
      t.string :hostname, null: false
      t.string :design_name
      t.string :location

      t.integer :role, null: false, default: 6
      t.integer :status, null: false, default: 0

      t.string :ip_address
      t.string :mac_address
      t.integer :vlan_id
      t.string :subnet
      t.string :vendor
      t.string :model
      t.string :serial_number
      t.text :notes

      t.timestamps

      t.index :hostname, unique: true
      t.index :location
      t.index :role
      t.index :status
      t.index :vendor
    end
  end
end
