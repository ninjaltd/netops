# Renders a flash message as a Turbo Stream response, replacing the #flash
# element on the page. Modeled on 37signals' Fizzy TurboFlash concern.
#
#   turbo_stream_flash notice: "Host was updated."
module TurboFlash
  extend ActiveSupport::Concern

  private
    def turbo_stream_flash(**flash_options)
      turbo_stream.replace(:flash, partial: "shared/flash", locals: { flash: flash_options })
    end
end
