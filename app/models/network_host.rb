require "ipaddr"

class NetworkHost < ApplicationRecord
  include Filterable, Sortable

  enum :role, {
    router: 0,
    switch: 1,
    firewall: 2,
    access_point: 3,
    nas: 4,
    server: 5,
    workstation: 6
  }, default: :workstation

  enum :status, {
    online: 0,
    offline: 1,
    maintenance: 2,
    decommissioned: 3
  }, default: :online

  HOSTNAME = /\A[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\z/i
  MAC      = /\A(?:[0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}\z/

  validates :hostname, presence: true, uniqueness: { case_sensitive: false }, format: { with: HOSTNAME, message: "must be a valid hostname (letters, digits and dashes)" }
  validates :design_name, presence: true
  validates :location, presence: true
  validates :mac_address, format: { with: MAC, message: "must be a valid MAC address like AA:BB:CC:DD:EE:FF" }, allow_blank: true
  validates :vlan_id, numericality: { only_integer: true, in: 1..4094 }, allow_nil: true

  before_validation { self.mac_address = mac_address&.upcase }

  validate :ipv4_address
  validate :cidr_subnet

  private
    def ipv4_address
      return if ip_address.blank?
      ip = IPAddr.new(ip_address)
      errors.add(:ip_address, "must be a valid IPv4 address") unless ip.ipv4? || ip.ipv4_mapped?
    rescue IPAddr::Error
      errors.add(:ip_address, "must be a valid IPv4 address")
    end

    def cidr_subnet
      return if subnet.blank?
      errors.add(:subnet, "must be a CIDR like 10.0.0.0/24") and return unless subnet.include?("/")
      addr = IPAddr.new(subnet)
      errors.add(:subnet, "must be a CIDR like 10.0.0.0/24") unless addr.ipv4?
    rescue IPAddr::Error
      errors.add(:subnet, "must be a CIDR like 10.0.0.0/24")
    end

  # Filter names accepted by `filtered` mapped to the scopes that apply them.
  def self.filter_scopes
    {
      "q" => :filtered_by_search,
      "location" => :filtered_by_location,
      "role" => :filtered_by_role,
      "status" => :filtered_by_status,
      "vendor" => :filtered_by_vendor
    }
  end

  scope :filtered_by_search, lambda { |q|
    where(
      "hostname LIKE :pattern OR design_name LIKE :pattern OR location LIKE :pattern OR" \
      " ip_address LIKE :pattern OR mac_address LIKE :pattern OR serial_number LIKE :pattern OR" \
      " vendor LIKE :pattern OR model LIKE :pattern",
      pattern: "%#{q}%"
    )
  }
  scope :filtered_by_location, ->(location) { where(location: location) }
  scope :filtered_by_role,     ->(role)     { where(role: role) }
  scope :filtered_by_status,   ->(status)   { where(status: status) }
  scope :filtered_by_vendor,   ->(vendor)   { where(vendor: vendor) }

  # Columns the table view may be sorted by.
  def self.sortable_columns
    %w[ hostname design_name location role status ip_address vendor created_at ]
  end

  def self.default_sort_column
    "hostname"
  end

  # Filter controls rendered by the shared filter form. Models that include
  # Filterable can provide this to get a filter bar for free.
  def self.filter_options
    {
      "q" => { label: "Search", input: :search },
      "location" => { label: "Location", input: :text },
      "role" => { label: "Role", input: :select, options: roles.keys },
      "status" => { label: "Status", input: :select, options: statuses.keys },
      "vendor" => { label: "Vendor", input: :text }
    }
  end

  def label
    "#{hostname} — #{design_name}"
  end
end
