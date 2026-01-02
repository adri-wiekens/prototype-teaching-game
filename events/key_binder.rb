require 'yaml'

module Events
  class KeyBinder
    include Singleton

    attr_reader :key_bindings
    attr_reader :inverted_actions

    def reload_key_bindings
      @key_bindings = YAML.load_file('assets/yaml/keymap.yaml')
      @inverted_actions = calculate_inverted_actions
    end

    def calculate_inverted_actions
      pre_result = self.key_bindings.fetch('other_keybinding', {})
      result = {}
      pre_result.each do |key, value|
        local_value = value
        local_value = 'space' if value == ' '
        result[local_value] ||= []
        result[local_value] << key.to_sym
      end
      result
    end
  end
end


