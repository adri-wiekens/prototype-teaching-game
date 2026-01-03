# frozen_string_literal: true

require 'yaml'

module Events
  class KeyBinder
    include Singleton

    attr_reader :key_bindings, :key_hold_actions, :key_down_actions

    def reload_key_bindings
      @key_bindings = YAML.load_file('assets/yaml/keymap.yaml')
      calculate_inverted_actions
    end

    def invert_hash(input)
      input.each_with_object({}) do |(action, key), h|
        h[key] ||= [] << action.to_sym
      end
    end

    def calculate_inverted_actions
      @key_hold_actions = invert_hash(key_bindings.dig('other_keybinding', 'key_hold') || {})
      @key_down_actions = invert_hash(key_bindings.dig('other_keybinding', 'key_down') || {})
    end
  end
end
