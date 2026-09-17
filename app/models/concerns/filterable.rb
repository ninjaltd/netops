# Applies a set of whitelisted filters to a relation.
#
#   NetworkHost.filtered(params)
#   # => #<ActiveRecord::Relation ...>
#
# Filters are plain query-string values. Keys that the model does not declare
# and blank values are silently ignored, so the raw params hash can be passed
# in without permitting anything.
#
# Models must implement these methods:
# - filter_scopes: a hash mapping filter names to the scope that applies them
module Filterable
  extend ActiveSupport::Concern

  included do
    scope :filtered, lambda { |filters = {}|
      relation = all
      (filters || {}).each do |name, value|
        next if value.blank?

        scope_name = filter_scopes[name.to_s]
        relation = relation.public_send(scope_name, value) if scope_name
      end
      relation
    }
  end
end
