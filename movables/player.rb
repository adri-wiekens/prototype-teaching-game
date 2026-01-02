module Movables
  class Player < Mobile
    def initialize
      super('assets/images/sprite_2.png', id: 'player', x: screen_width/2, y: screen_height/2, width: 40, height: 40)
      self.gravity_affected= false
    end

    def key_bindings
      ::Events::KeyBinder.instance.key_bindings
    end

    def other_actions
      ::Events::KeyBinder.instance.inverted_actions
    end

    def handle_player_input(event)
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

      handle_other_events(event)
    end

    def handle_other_events(event)
      return unless other_actions.key?(event.key)
      other_actions[event.key].each do |action|
        case action
        when :shoot
          shoot
        else
          p "I don't know what to do yet!"
        end
      end
    end
  end
end
