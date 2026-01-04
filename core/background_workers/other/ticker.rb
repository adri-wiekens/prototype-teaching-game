# frozen_string_literal: true

require_relative '../background_worker'

module Core
  module BackgroundWorkers
    module Other
      class Ticker < BackgroundWorker
        def say_something
          p "#{name} : every second #{rand(10000..30000)}"
        end

        def shoot!
          Core::Engine.instance.player&.shoot
        end

        def run_task
          say_something
          shoot!
        end
      end
    end
  end
end
