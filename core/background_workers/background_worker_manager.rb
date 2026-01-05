# frozen_string_literal: true

require 'singleton'
require 'concurrent-ruby'

require_relative './network/connection'
require_relative './other/ticker'
require_relative './background_worker'


module Core
  module BackgroundWorkers
    class BackgroundWorkerManager
      include Singleton

      attr_reader :active_connection
      attr_reader :max_threads
      attr_reader :connection_objects

      SUPPORTED_BACKGROUND_WORKERS = [:cleaner, :connection, :ticker].freeze

      def build_connection
        @connection_objects ||= {}
        @thread_id_provider = 0
        @max_threads = SUPPORTED_BACKGROUND_WORKERS.length
        @active_connection = Concurrent::FixedThreadPool.new(max_threads)
        build_cleaner
      end

      def build_cleaner
        add_worker(:cleaner)
      end

      def get_thread_id
        @thread_id_provider += 1
      end

      private def initialize_worker_from_type(worker_type, interval: 1)
        case worker_type
        when :connection
          Network::Connection.new(get_thread_id)
        when :ticker
          Other::Ticker.new(get_thread_id, interval:)
        when :background_worker
          BackgroundWorker.new(get_thread_id)
        else
          raise "HOW DID YOU EVEN GET HERE?!!??!!"
        end
      end

      def add_worker(worker_type)
        raise "invalid worker type #{worker_type}" unless SUPPORTED_BACKGROUND_WORKERS.include?(worker_type)

        self.active_connection.post do
          p "WORKER ALREADY ACTIVE ! #{worker_type.inspect}" unless self.connection_objects[worker_type].nil?
          self.connection_objects[worker_type] = initialize_worker_from_type(worker_type)

          self.connection_objects[worker_type].run
        end
      end
    end
  end
end
