# frozen_string_literal: true

require 'yaml'
require 'active_support/core_ext/hash/keys'

module Core
  class GameSettings
    include Singleton

    attr_reader :settings

    def reload_settings
      @settings = YAML.load_file('assets/yaml/game_settings.yaml')
    end

    def resolution
      settings.fetch('resolution', {}).symbolize_keys
    end

    def calculate_inverted_actions
      @key_hold_actions = invert_hash(key_bindings.dig('other_keybinding', 'key_hold') || {})
      @key_down_actions = invert_hash(key_bindings.dig('other_keybinding', 'key_down') || {})
    end
  end
end
