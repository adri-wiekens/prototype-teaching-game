# frozen_string_literal: true

module Core
  module BackgroundWorkers
    class BackgroundWorker

      attr_reader :id
      attr_reader :exit
      attr_reader :interval
      
      def initialize(number, interval: 1)
        @id = number
        @interval = interval
        @exit = false
      end

      def remove_interval
        # in case you wish to manually handle the interval in the run_task
        @interval = nil
      end

      def name
        "#{self.class.name} - #{self.id}"
      end

      def stop
        @exit = true
      end

      def manager
        Core::BackgroundWorkers::BackgroundWorkerManager.instance
      end

      def run_task
        p "#{name} : This is just a default task."
        p "#{name} : you really should not be using this task directly, but override it in child classes"
        p "#{name} : I will sleep now, and then just end"
        sleep(2)
        stop
      end

      def run
        while !self.exit do
          run_task
          sleep(@interval) unless interval.nil?
        end
        manager.connection_objects.reject! {|_key, val| val.exit }
      end
    end
  end
end
