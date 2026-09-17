require "test_helper"

class SortableTest < ActiveSupport::TestCase
  test "sorts ascending by a declared column" do
    assert_equal %w[atl-sw-01 denver-ws-01 hq-fw-01 hq-sw-01],
                 NetworkHost.sorted("hostname", "asc").map(&:hostname)
  end

  test "sorts descending by a declared column" do
    assert_equal %w[hq-sw-01 hq-fw-01 denver-ws-01 atl-sw-01],
                 NetworkHost.sorted("hostname", "desc").map(&:hostname)
  end

  test "unknown column falls back to the default sort column" do
    default = NetworkHost.sorted("bogus_column", "asc").to_a
    assert_equal NetworkHost.order(:hostname, :id).to_a, default
  end

  test "unknown direction falls back to ascending" do
    assert_equal NetworkHost.sorted("hostname", "asc").to_a,
                 NetworkHost.sorted("hostname", "sideways").to_a
  end

  test "nil params are safe" do
    assert_kind_of Array, NetworkHost.sorted(nil, nil).to_a
  end
end
