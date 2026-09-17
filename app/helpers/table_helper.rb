module TableHelper
  # Renders a sortable column header. The current sort/filter query params are
  # preserved, the page number is reset, and the link targets the given Turbo
  # Frame so only the table reloads.
  #
  #   sortable_header :hostname, "Hostname", frame: "hosts_table"
  def sortable_header(column, label, frame:)
    column  = column.to_s
    current = params[:sort].presence == column ? params[:direction].to_s : nil
    next_direction = current == "asc" ? "desc" : "asc"
    arrow = current == "asc" ? " ↑" : current == "desc" ? " ↓" : ""

    link_to "#{label}#{arrow}".strip,
            url_for(request.query_parameters.merge(sort: column, direction: next_direction, page: nil)),
            class: "sortable-header sortable-#{column}#{current ? " is-#{current}" : ""}",
            title: "Sort by #{label}",
            data: { turbo_frame: frame }
  end
end
