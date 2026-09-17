# Netops

A lightweight network host inventory for Rails. Track routers, switches, firewalls,
access points, NAS devices, servers and workstations in one place — with search,
filtering, sorting and pagination.

Built with Rails 8.1, Hotwire (Turbo + Stimulus) and SQLite. No JavaScript framework
beyond the standard importmap setup.

## Features

- **Full CRUD** for network hosts (create, view, edit, delete)
- **Roles**: router, switch, firewall, access point, NAS, server, workstation
- **Statuses**: online, offline, maintenance, decommissioned
- **Network fields**: IPv4 address, MAC address (normalised to upper case), VLAN ID, CIDR subnet
- **Hardware fields**: vendor, model, serial number, location, free-text notes
- **Free-text search** across hostname, design name, location, IP, MAC, vendor, model and serial number
- **Filters** by search, location, role, status and vendor (combinable)
- **Column sorting** (click a table header to sort, click again to reverse; defaults to hostname)
- **Pagination** with preserved filter/sort state
- **Flash messages** rendered via Turbo Streams (works with both full page loads and Turbo navigation)

## Requirements

- Ruby 3.3+ (see `.ruby-version`)
- SQLite 3.8+ (bundled with the `sqlite3` gem)

## Getting started

```bash
git clone https://github.com/ninjaltd/netops.git
cd netops

bundle install
bin/rails db:prepare     # creates the schema
bin/rails db:seed        # loads the demo inventory (~45 hosts, deterministic seed)
bin/rails server
```

Then open <http://localhost:3000>.

To reset to a clean seeded state:

```bash
bin/rails db:reset
```

## Running the tests

```bash
bin/rails test
```

The suite covers the model validations (hostname, IP, CIDR, MAC, VLAN), the
`Filterable` and `Sortable` concerns, and the full controller flow
(index/new/create/show/edit/update/destroy, including error re-renders).

## Project structure

```
app/
├── controllers/
│   ├── concerns/
│   │   ├── paginatable.rb        # shared pagination (page/per, safe integer params)
│   │   └── turbo_flash.rb        # flash messages as Turbo Stream responses
│   └── network_hosts_controller.rb
├── models/
│   ├── concerns/
│   │   ├── filterable.rb         # whitelisted filter → scope mapping
│   │   └── sortable.rb           # whitelisted column sorting
│   └── network_host.rb           # validations + filter/sort declarations
└── views/
    ├── network_hosts/            # index, show, new, edit + partials
    └── shared/                   # filter form, pagination, flash partial
```

`Filterable` and `Sortable` are model concerns: each model declares which
filter keys and sort columns it accepts, and the concerns apply them through
whitelisted scopes — unknown keys are silently ignored, so controller params
never reach `where`/`order` unvalidated.

## Validation rules

| Field | Rule |
|---|---|
| hostname | required, unique (case-insensitive), `[a-z0-9-]` hostname format |
| design_name | required |
| location | required |
| ip_address | valid IPv4 (validated with `IPAddr`) |
| mac_address | `AA:BB:CC:DD:EE:FF` format, stored upper-case |
| subnet | explicit IPv4 CIDR, e.g. `10.0.0.0/24` |
| vlan_id | integer 1–4094 |

## Deployment

The app is configured for SQLite in `config/database.yml`. For production on a
managed host, point the `production` database config at persistent storage, set
`RAILS_SERVE_STATIC_FILES`, and precompile assets as usual:

```bash
RAILS_ENV=production bin/rails assets:precompile
RAILS_ENV=production bin/rails db:prepare
```

Any web server that can speak to Puma (or Puma directly) will work.

## Gem notes

- `json` is pinned to `~> 2.7`. json 3.x changed `JSON.parse` to
  keyword-only options, which breaks ActiveSupport 8.1's positional call and
  therefore cookie/session decryption.
