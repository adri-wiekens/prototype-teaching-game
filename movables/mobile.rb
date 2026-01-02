require 'forwardable'

require_relative './movable.rb'

module Movables
  class Mobile < Movable
    extend Forwardable

    attr_reader :current_hp
    attr_reader :max_hp

    def initialize(file_path, id:, **additional_parameters)
      super(file_path, id:, **additional_parameters)
      @current_hp = startup_hp
    end

    def startup_hp
      mob_db_get(id)["current_hp"]
    end

    def update_attributes
      super
      @max_hp = mob_db_get(id)["hp"]
    end

     def update_position(friction)
      super

      ricochet(:x) if self.x < 0 || self.x > screen_width  - self.width
      ricochet(:y) if self.y < 0 || self.y > screen_height - self.height
    end

    def shoot
      engine.movables << Bullet.new(mobile: self)
    end

    def ricochet(direction)
      max_height = screen_height - self.height
      max_width = screen_width - self.width
      case direction
      when :x
        @velocity_x = -@velocity_x
        self.x = max_width if self.x > max_width
        self.x = 0 if self.x < 0
        damage_collision(@velocity_x*@velocity_x) if velocity_x.abs > 5
      when :y
        @velocity_y = -@velocity_y
        self.y = max_height if self.y > max_height
        self.y = 0 if self.y < 0
        damage_collision(@velocity_y*@velocity_y) if velocity_y.abs > 5
      else
        raise 'unsupported direction'
      end
    end

    def damage_collision(damage)
      @current_hp -= damage
      @current_hp = 0 if @current_hp < 0
    end
  end
end
