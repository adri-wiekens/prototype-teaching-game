module Movables
  class Player < Mobile
    def initialize
      super('assets/images/sprite_2.png', id: 'player', x: screen_width/2, y: screen_height/2, width: 40, height: 40)
    end

    def key_bindings
      ::Events::KeyBinder.instance.key_bindings
    end

    def key_hold_actions
      ::Events::KeyBinder.instance.key_hold_actions
    end

    def key_down_actions
      ::Events::KeyBinder.instance.key_down_actions
    end

    def handle_key_held_input(event)
      # movement
      forward = self.key_bindings.dig('movement', 'forward')
      backward =  self.key_bindings.dig('movement', 'backward')
      turn_left = self.key_bindings.dig('movement', 'turn_left')
      turn_right = self.key_bindings.dig('movement', 'turn_right')
      strafe_left = self.key_bindings.dig('movement', 'strafe_left')
      strafe_right = self.key_bindings.dig('movement', 'strafe_right')

      if(!turn_left.nil? && turn_left == event.key)
        rotate_to(:left)
      elsif(!turn_right.nil? && turn_right == event.key)
        rotate_to(:right)
      elsif(!forward.nil? && forward == event.key)
        accelerate(:forward)
      elsif(!backward.nil? && backward == event.key)
        accelerate(:backward)
      elsif(!strafe_left.nil? && strafe_left == event.key)
        accelerate(:left)
      elsif(!strafe_right.nil? && strafe_right == event.key)
        accelerate(:right)
      end

      handle_other_events(event, key_hold_actions)
    end

    def handle_key_down_input(event)      
      handle_other_events(event, key_down_actions)
    end

    def handle_other_events(event, keymap)
      return unless keymap.key?(event.key)
      keymap[event.key].each do |action|        
        case action
        when :shoot
          shoot
        when :debug
          Core::Gui.instance.toggle_debug_info
        when :unknown
          p "something"
        when :play_sound
          p "sound!"
          sound = Sound.new('assets/audio/lalala-161733.mp3')
          sound.play
        else
          p "I don't know what to do yet!"
        end
      end
    end
  end
end
