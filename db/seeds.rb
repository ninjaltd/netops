# A believable small-business network inventory: headquarters, three branch
# offices and a data center. Enough rows (45) to exercise pagination.

VENDORS = {
  "router" => [["Cisco", "ISR 4451"], ["Juniper", "SRX345"], ["MikroTik", "CCR2004"]],
  "switch" => [["Cisco", "Catalyst 9300-48T"], ["HPE", "Aruba 2930F"], ["Ubiquiti", "Pro Max 24 PoE"], ["Arista", "DCS-7050SX3"]],
  "firewall" => [["Fortinet", "FortiGate 100F"], ["Palo Alto", "PA-440"], ["Cisco", "ISA 3000"]],
  "access_point" => [["Ubiquiti", "U6 Pro"], ["Aruba", "AP-635"], ["Ruckus", "R750"]],
  "nas" => [["Synology", "RS3621xs+"], ["QNAP", "TS-483"]],
  "server" => [["Dell", "PowerEdge R650"], ["HPE", "ProLiant DL380 Gen10"], ["Supermicro", "SYS-510C"]],
  "workstation" => [["Dell", "OptiPlex 7010"], ["Lenovo", "ThinkCentre M95a"], ["Apple", "Mac mini M2"]]
}.freeze

SITES = {
  "hq" => { name: "HQ — Rack A", subnet: "10.0.0.0/24" },
  "atl" => { name: "Atlanta — Branch 2", subnet: "10.0.1.0/24" },
  "austin" => { name: "Austin — Branch 3", subnet: "10.0.2.0/24" },
  "denver" => { name: "Denver — Branch 4", subnet: "10.0.3.0/24" },
  "dc" => { name: "Data Center — Colo 1", subnet: "10.1.0.0/24" }
}.freeze

def random_mac(rng)
  6.times.map { format("%02X", rng.rand(0..255)) }.join(":")
end

rng = Random.new(42)
counters = Hash.new(0)
hosts = []

def build_host(rng, counters, site:, role:, prefix:, design:)
  site_config = SITES[site]
  vendor, model = VENDORS[role].sample(random: rng)
  n = counters[site] += 1
  base_octet = site_config[:subnet].split("/").first.sub(/\.\d+\z/, "")

  {
    hostname: "#{site}-#{prefix}-#{format('%02d', n)}",
    design_name: design,
    location: site_config[:name],
    role: role,
    status: rng.rand < 0.8 ? "online" : %w[offline maintenance decommissioned].sample(random: rng), 
    ip_address: "#{base_octet}.#{10 + n}",
    mac_address: random_mac(rng),
    vlan_id: role == "access_point" ? 40 : 10 + n,
    subnet: site_config[:subnet],
    vendor: vendor,
    model: model,
    serial_number: format("SN-%s-%06d", vendor.split(" ").first.upcase, rng.rand(100_000..999_999)),
    notes: design
  }
end

# Core infrastructure for each site.
[
  ["hq", "firewall", "fw", "HQ border firewall"],
  ["hq", "switch", "sw", "HQ core switch"],
  ["hq", "switch", "sw", "HQ access switch, office floor"],
  ["hq", "nas", "nas", "HQ file & backup target"],
  ["hq", "server", "srv", "HQ internal apps"],
  ["hq", "access_point", "ap", "HQ office WiFi"],
  ["hq", "workstation", "ws", "Networking desk"],
  ["atl", "firewall", "fw", "Atlanta edge firewall"],
  ["atl", "switch", "sw", "Atlanta branch switch"],
  ["atl", "access_point", "ap", "Atlanta branch WiFi"],
  ["atl", "workstation", "ws", "Atlanta office PC"],
  ["austin", "firewall", "fw", "Austin edge firewall"],
  ["austin", "switch", "sw", "Austin branch switch"],
  ["austin", "access_point", "ap", "Austin branch WiFi"],
  ["austin", "workstation", "ws", "Austin office PC"],
  ["denver", "firewall", "fw", "Denver edge firewall"],
  ["denver", "switch", "sw", "Denver branch switch"],
  ["denver", "access_point", "ap", "Denver branch WiFi"],
  ["denver", "workstation", "ws", "Denver office PC"],
  ["dc", "switch", "sw", "Colo top-of-rack 1"],
  ["dc", "switch", "sw", "Colo top-of-rack 2"],
  ["dc", "server", "srv", "Primary database"],
  ["dc", "server", "srv", "Replica database"],
  ["dc", "nas", "nas", "Cold storage"]
].each do |site, role, prefix, design|
  hosts << build_host(rng, counters, site: site, role: role, prefix: prefix, design: design)
end

# Extra workstations and access points to push past two pages of 25.
20.times do |i|
  site = %w[hq atl austin denver][i % 4]
  role = i.odd? ? "workstation" : "access_point"
  design = role == "workstation" ? "User workstation" : "WiFi access point"
  hosts << build_host(rng, counters, site: site, role: role, prefix: role == "workstation" ? "ws" : "ap", design: design)
end

if NetworkHost.count.positive?
  puts "Skipping seeds: #{NetworkHost.count} hosts already present. Run `bin/rails db:reset` to reseed."
else
  NetworkHost.insert_all!(hosts)
  puts "Seeded #{NetworkHost.count} network hosts."
end
