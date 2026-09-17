require "test_helper"

class FilterableTest < ActiveSupport::TestCase
  def by_id(relation)
    relation.to_a.sort_by(&:id)
  end

  test "filtered by status" do
    expected = [network_hosts(:hq_core_switch), network_hosts(:hq_border_firewall)]
    assert_equal expected.sort_by(&:id), by_id(NetworkHost.filtered("status" => "online"))
  end

  test "filtered by role" do
    expected = [network_hosts(:hq_core_switch), network_hosts(:atl_branch_switch)]
    assert_equal expected.sort_by(&:id), by_id(NetworkHost.filtered("role" => "switch"))
  end

  test "filtered by location" do
    expected = [network_hosts(:hq_core_switch), network_hosts(:hq_border_firewall)]
    assert_equal expected.sort_by(&:id), by_id(NetworkHost.filtered("location" => "HQ — Rack A"))
  end

  test "filtered by free-text search across fields" do
    expected = [network_hosts(:hq_core_switch), network_hosts(:atl_branch_switch)]
    assert_equal expected.sort_by(&:id), by_id(NetworkHost.filtered("q" => "Catalyst"))
    assert_includes NetworkHost.filtered("q" => "10.0.3.21"), network_hosts(:denver_workstation)
    assert_includes NetworkHost.filtered("q" => "forti"), network_hosts(:hq_border_firewall)
  end

  test "filters combine" do
    assert_equal [network_hosts(:hq_core_switch)],
                 NetworkHost.filtered("role" => "switch", "status" => "online").to_a
  end

  test "unknown filters and blank values are ignored" do
    assert_equal NetworkHost.count, NetworkHost.filtered("bogus" => "x", "q" => "").count
  end

  test "accepts an ActionController::Parameters object" do
    params = ActionController::Parameters.new("status" => "offline")
    assert_equal [network_hosts(:atl_branch_switch)], NetworkHost.filtered(params).to_a
  end
end
