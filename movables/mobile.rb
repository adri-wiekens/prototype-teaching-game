require 'forwardable'

require_relative './movable'
require_relative '../unmovables/world'

module Movables
  class Mobile < Movable
    extend Forwardable

    attr_reader :current_hp
    attr_reader :max_hp
    attr_reader :name

    def initialize(file_path, id:, **additional_parameters)
      super(file_path, id:, **additional_parameters)
      @selectable = true
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

      ricochet(:x) if self.x < min_horizontal || self.x > max_horizontal
      ricochet(:y) if self.y > max_depth || self.y < max_height
    end

    def shoot
      engine << Bullet.new(mobile: self)
    end

    def world
      Unmovables::World.current
    end

    def max_height
      world.limits[:sky]
    end

    def max_depth
      world.limits[:ground] - self.height
    end

    def min_horizontal
      world.limits[:west]
    end

    def max_horizontal
      world.limits[:east] - self.width
    end

    def ricochet(direction)
      case direction
      when :x
        @velocity_x = -@velocity_x
        self.x = max_horizontal if self.x > max_horizontal
        self.x = min_horizontal if self.x < min_horizontal
        damage_collision(@velocity_x*@velocity_x) if velocity_x.abs > 10
      when :y
        @velocity_y = -@velocity_y
        self.y = max_height if self.y < max_height
        self.y = max_depth if self.y > max_depth
        damage_collision(@velocity_y*@velocity_y) if velocity_y.abs > 10
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
