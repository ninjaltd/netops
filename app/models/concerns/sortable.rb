# Applies a whitelisted column sort to a relation.
#
#   NetworkHost.sorted(params[:sort], params[:direction])
#   # => #<ActiveRecord::Relation ...>
#
# Columns the model does not declare fall back to its default sort column,
# and any direction other than "asc" or "desc" falls back to ascending, so
# raw params can be passed in safely. A stable secondary order by id keeps
# pagination consistent across pages.
#
# Models must implement these methods:
# - sortable_columns: an array of column names that may be sorted
# - default_sort_column: the column to sort by when none is given
module Sortable
  extend ActiveSupport::Concern

  included do
    scope :sorted, lambda { |column = nil, direction = nil|
      column = sortable_columns.include?(column.to_s) ? column.to_s : default_sort_column
      direction = direction.to_s == "desc" ? "desc" : "asc"
      # Both values are whitelisted above, so interpolating them is safe.
      order(Arel.sql("#{column} #{direction}"), :id)
    }
  end
end
