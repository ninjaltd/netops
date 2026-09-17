require "test_helper"

class NetworkHostTest < ActiveSupport::TestCase
  test "valid host" do
    assert network_hosts(:hq_core_switch).valid?
  end

  test "requires hostname, design name and location" do
    host = NetworkHost.new
    assert_not host.valid?
    assert_includes host.errors[:hostname], "can't be blank"
    assert_includes host.errors[:design_name], "can't be blank"
    assert_includes host.errors[:location], "can't be blank"
  end

  test "hostname must be unique regardless of case" do
    host = NetworkHost.new(hostname: "HQ-SW-01", design_name: "Dup", location: "HQ — Rack A")
    assert_not host.valid?
    assert_includes host.errors[:hostname], "has already been taken"
  end

  test "hostname format is enforced" do
    host = NetworkHost.new(hostname: "-bad-", design_name: "Bad", location: "HQ — Rack A")
    assert_not host.valid?
    assert host.errors[:hostname].any?
  end

  test "ip, mac and subnet formats are enforced" do
    host = NetworkHost.new(
      hostname: "ok-01", design_name: "Ok", location: "HQ — Rack A",
      ip_address: "999.1.1.1", mac_address: "nope", subnet: "10.0.0.0"
    )
    assert_not host.valid?
    assert host.errors[:ip_address].any?
    assert host.errors[:mac_address].any?
    assert host.errors[:subnet].any?
  end

  test "mac address is upper-cased on save" do
    host = NetworkHost.create!(hostname: "mac-01", design_name: "Mac", location: "HQ", mac_address: "aa:bb:cc:dd:ee:ff")
    assert_equal "AA:BB:CC:DD:EE:FF", host.reload.mac_address
  end

  test "vlan must be within 1..4094" do
    host = NetworkHost.new(hostname: "v-01", design_name: "V", location: "HQ", vlan_id: 9999)
    assert_not host.valid?
    assert host.errors[:vlan_id].any?
  end
end
