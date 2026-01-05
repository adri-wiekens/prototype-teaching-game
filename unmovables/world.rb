# frozen_string_literal: true

require 'yaml'

module Unmovables
  class World
    include Singleton

    def world=(val)
      reload_world
      @world = worlds_hash.fetch(val, worlds_hash['world_1'])
    end

    def reload_world
      @worlds_hash ||= YAML.load_file('assets/yaml/worlds.yaml')
      self
    end

    def limits
      {
        east: world.dig('limits', 'east'),
        sky: world.dig('limits', 'sky_limit'),
        west: world.dig('limits', 'west'),
        ground: world.dig('limits', 'ground_limit')
      }
    end

    class << self
      def current
        instance.reload_world
        instance.world = ('world_1')
        instance
      end

      def world=(val)
        current.world = val
      end
    end

    private

    attr_reader :worlds_hash, :world
  end
end
