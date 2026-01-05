# frozen_string_literal: true

require_relative '../background_worker'

module Core
  module BackgroundWorkers
    module Other
      class Ticker < BackgroundWorker
        def run_task
          # Do something every second
        end
      end
    end
  end
end
