class NetworkHostsController < ApplicationController
  include Paginatable
  include TurboFlash

  before_action :set_network_host, only: %i[ show edit update destroy ]

  # GET /network_hosts
  #
  # The table (filters, sortable headers, pagination) lives in a Turbo Frame,
  # so this action serves both the full page and just the frame's content.
  def index
    @network_hosts = paginated(
      NetworkHost
        .sorted(params[:sort], params[:direction])
        .filtered(params)
    )
  end

  # GET /network_hosts/:id
  def show
  end

  # GET /network_hosts/new
  def new
    @network_host = NetworkHost.new
  end

  # GET /network_hosts/:id/edit
  def edit
  end

  # POST /network_hosts
  def create
    @network_host = NetworkHost.new(network_host_params)

    if @network_host.save
      redirect_to network_host_path(@network_host), notice: "Host #{@network_host.hostname} was added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH /network_hosts/:id
  def update
    if @network_host.update(network_host_params)
      if turbo_frame_request?
        # The update came from the index table: replace just that row and
        # flash, without reloading the page.
        render turbo_stream: [
          turbo_stream.replace(@network_host, partial: "network_hosts/network_host", locals: { network_host: @network_host }),
          turbo_stream_flash(notice: "Host #{@network_host.hostname} was updated.")
        ]
      else
        redirect_to network_host_path(@network_host), notice: "Host #{@network_host.hostname} was updated."
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /network_hosts/:id
  def destroy
    hostname = @network_host.hostname

    if turbo_frame_request?
      # The delete came from the index table: remove just that row and flash.
      @network_host.destroy
      render turbo_stream: [
        turbo_stream.remove(@network_host),
        turbo_stream_flash(notice: "Host #{hostname} was removed.")
      ]
    else
      @network_host.destroy
      redirect_to network_hosts_path, notice: "Host #{hostname} was removed."
    end
  end

  private
    def set_network_host
      @network_host = NetworkHost.find(params[:id])
    end

    def network_host_params
      params.require(:network_host).permit(
        :hostname, :design_name, :location, :role, :status,
        :ip_address, :mac_address, :vlan_id, :subnet,
        :vendor, :model, :serial_number, :notes
      )
    end
end
