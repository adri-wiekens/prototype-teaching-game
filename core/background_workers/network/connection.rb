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

        def say_something
          p "#{name} says : #{rand(10000..30000)}"
        end

        def run_task
          number = rand(1..3)
          sleep(number)            
          say_something
        end
      end
    end
  end
end
