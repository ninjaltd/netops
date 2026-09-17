# Adds page/per pagination to any relation and exposes the resulting state
# to the view.
#
#   def index
#     @network_hosts = paginated(
#       NetworkHost.sorted(params[:sort], params[:direction]).filtered(params)
#     )
#   end
#
# The view then uses the helper methods: page_number, per_page, total_count,
# total_pages, has_more_pages? and page_entries_info. Any model works — the
# concern only cares about the relation it is handed.
module Paginatable
  extend ActiveSupport::Concern

  DEFAULT_PER_PAGE = 25
  MAX_PER_PAGE     = 100

  included do
    helper_method :page_number, :per_page, :total_count, :total_pages, :has_more_pages?, :page_entries_info
  end

  private
    def paginated(relation)
      @total_count = relation.count
      relation.limit(per_page).offset((page_number - 1) * per_page).to_a
    end

    def page_number
      [params[:page].to_i, 1].max
    end

    def per_page
      requested = params[:per].to_i
      requested = DEFAULT_PER_PAGE if requested <= 0
      [requested, MAX_PER_PAGE].min
    end

    def total_count
      @total_count || 0
    end

    def total_pages
      (total_count.to_f / per_page).ceil
    end

    def has_more_pages?
      total_count > page_number * per_page
    end

    def page_entries_info
      return "No records" if total_count.zero?

      from = (page_number - 1) * per_page + 1
      to   = [total_count, page_number * per_page].min
      "Showing #{from}–#{to} of #{total_count} record#{total_count == 1 ? "" : "s"}"
    end
end
