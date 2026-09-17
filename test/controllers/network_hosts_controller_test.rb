require "test_helper"

class NetworkHostsControllerTest < ActionDispatch::IntegrationTest
  TURBO_STREAM_ACCEPT = "text/vnd.turbo-stream.html, text/html"

  test "index renders the table inside the hosts frame" do
    get network_hosts_path, headers: { "Turbo-Frame" => "hosts_table" }
    assert_response :success
    assert_select "turbo-frame#hosts_table"
    assert_select "table"
    assert_select "tr##{dom_id(network_hosts(:hq_core_switch))}"
  end

  test "index applies status filter" do
    get network_hosts_path, params: { status: "online" }, headers: { "Turbo-Frame" => "hosts_table" }
    assert_response :success
    assert_select "tr##{dom_id(network_hosts(:hq_core_switch))}"
    assert_select "tr##{dom_id(network_hosts(:atl_branch_switch))}", count: 0
  end

  test "index applies search and role filter together" do
    get network_hosts_path, params: { role: "switch", q: "Catalyst" }, headers: { "Turbo-Frame" => "hosts_table" }
    assert_response :success
    assert_select "tr##{dom_id(network_hosts(:hq_core_switch))}"
    assert_select "tr##{dom_id(network_hosts(:hq_border_firewall))}", count: 0
  end

  test "index sorts by hostname descending" do
    get network_hosts_path, params: { sort: "hostname", direction: "desc" }, headers: { "Turbo-Frame" => "hosts_table" }
    assert_response :success
    hostnames = Nokogiri::HTML.parse(response.body).css("tbody td.hostname-cell a").map(&:text)
    assert_equal hostnames.sort.reverse, hostnames
  end

  test "index paginates" do
    get network_hosts_path, params: { per: 2 }, headers: { "Turbo-Frame" => "hosts_table" }
    assert_response :success
    assert_select "tr[id^='network_host_']", count: 2
    assert_match "Showing 1–2 of 4", response.body

    get network_hosts_path, params: { per: 2, page: 2 }, headers: { "Turbo-Frame" => "hosts_table" }
    assert_select "tr[id^='network_host_']", count: 2
    assert_match "Showing 3–4 of 4", response.body
  end

  test "show renders the host" do
    get network_host_path(network_hosts(:hq_core_switch))
    assert_response :success
    assert_match "HQ core switch", response.body
  end

  test "new renders the form" do
    get new_network_host_path
    assert_response :success
    assert_select "form"
  end

  test "edit renders the form" do
    get edit_network_host_path(network_hosts(:hq_core_switch))
    assert_response :success
    assert_select "input[value='HQ core switch']"
  end

  test "create redirects to show on success" do
    assert_difference "NetworkHost.count", 1 do
      post network_hosts_path, params: {
        network_host: { hostname: "new-sw-01", design_name: "New switch", location: "HQ — Rack A", role: "switch" }
      }
    end
    assert_redirected_to network_host_path(NetworkHost.last)
    follow_redirect!
    assert_match "New switch", response.body
  end

  test "create re-renders new with errors on failure" do
    assert_no_difference "NetworkHost.count" do
      post network_hosts_path, params: { network_host: { hostname: "", design_name: "", location: "" } }
    end
    assert_response :unprocessable_entity
    assert_match "can&#39;t be blank", response.body
  end

  test "update from a regular page redirects to show" do
    patch network_host_path(network_hosts(:hq_core_switch)), params: { network_host: { status: "offline" } }
    assert_redirected_to network_host_path(network_hosts(:hq_core_switch))
    assert network_hosts(:hq_core_switch).reload.offline?
  end

  test "update from inside the frame responds with a Turbo Stream" do
    patch network_host_path(network_hosts(:atl_branch_switch)),
          params: { network_host: { status: "online" } },
          headers: { "Turbo-Frame" => "hosts_table", "ACCEPT" => TURBO_STREAM_ACCEPT }
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_select "turbo-stream[action='replace'][target='#{dom_id(network_hosts(:atl_branch_switch))}']"
    assert_select "turbo-stream[action='replace'][target='flash']"
    assert network_hosts(:atl_branch_switch).reload.online?
  end

  test "destroy from a regular page redirects to index" do
    assert_difference "NetworkHost.count", -1 do
      delete network_host_path(network_hosts(:denver_workstation))
    end
    assert_redirected_to network_hosts_path
  end

  test "destroy from inside the frame responds with a Turbo Stream" do
    assert_difference "NetworkHost.count", -1 do
      delete network_host_path(network_hosts(:denver_workstation)),
             headers: { "Turbo-Frame" => "hosts_table", "ACCEPT" => TURBO_STREAM_ACCEPT }
    end
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_select "turbo-stream[action='remove'][target='#{dom_id(network_hosts(:denver_workstation))}']"
    assert_select "turbo-stream[action='replace'][target='flash']"
  end
end
