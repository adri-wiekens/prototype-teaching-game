# frozen_string_literal: true

require_relative '../background_worker'

module Core
  module BackgroundWorkers
    module Network
      class Connection < BackgroundWorker
        def initialize(number)
          super(number)
          remove_interval
        end

        def run_task
          number = rand(1..3)
          sleep(number)
        end
      end
    end
  end
end
