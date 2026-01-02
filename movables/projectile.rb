require 'forwardable'

require_relative './movable.rb'
require_relative '../temporary_visibles/explosion.rb'

module Movables
  class Projectile < Movable
    extend Forwardable

    attr_reader :muzzle_velocity

    def initialize(file_path, rotation:, start_velocity_x:, start_velocity_y:, id:, **additional_parameters)
      super(file_path, id:, **additional_parameters)
      self.rotate = rotation
      @muzzle_velocity = get_muzzle_velocity
      angle = self.rotate * Math::PI / 180
      @velocity_x -= Math.sin(-angle) * muzzle_velocity
      @velocity_y -= Math.cos(angle) * muzzle_velocity
      self.friction_affected = false
    end

    def get_muzzle_velocity
      mob_db_get(id).fetch("muzzle_velocity", 0)
    end

    def explode
      middle_x = self.width/2 + self.x
      middle_y = self.height/2 + self.y
      self.remove_me
      engine.explode(middle_x, middle_y)
      self.remove
    end

    def update_position(friction)
      super
      if x > screen_width || x < 0
        self.remove_me
        self.remove
      elsif y > screen_height
        self.remove_me
        self.remove
      end
    end

    def engine
      Core::Engine.instance
    end
  end
end
