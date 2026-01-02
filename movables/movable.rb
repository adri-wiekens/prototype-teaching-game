require 'forwardable'

module Movables
  class Movable < Ruby2D::Image
    extend Forwardable

    attr_reader :velocity_x
    attr_reader :velocity_y
    attr_reader :rotation_speed
    attr_reader :acceleration
    attr_reader :friction_affected
    attr_reader :gravity_affected
    attr_reader :id
    attr_reader :mark_for_remove

    def engine
      Core::Engine.instance
    end

    def screen_width
      engine.bounds[:width]
    end

    def screen_height
      engine.bounds[:height]
    end

    def mob_db_get(id)
      Db::ResourceConnector.instance.get_mobile_properties(id)
    end

    def initialize(file_path, id:, **additional_parameters)
      super(file_path, **additional_parameters)
      @mark_for_remove = false
      self.friction_affected = true
      self.gravity_affected = true
      @velocity_x = 0.0
      @velocity_y = 0.0
      @id = id

      update_attributes
    end

    def remove_me
      @mark_for_remove = true
      self.remove
    end

    def gravity_affected=(val)
      raise "Only true or false!" unless val == true || val == false
      @gravity_affected = val
    end

    def friction_affected=(val)
      raise "Only true or false!" unless val == true || val == false
      @friction_affected = val
    end

    def apply_gravity(gravity)
      return unless self.gravity_affected
      @velocity_y +=  gravity
    end

    def update_attributes
      @rotation_speed = mob_db_get(id)["rotation_speed"]
      @acceleration = mob_db_get(id)["acceleration"]
    end

    def rotate_to(direction)
      case direction
      when :left
        self.rotate -= rotation_speed
      when :right
        self.rotate += rotation_speed
      else
        raise 'unsupported direction'
      end
    end

    def update_position(friction)
      self.x += self.velocity_x
      self.y += self.velocity_y

      return unless self.friction_affected
      @velocity_x *= friction
      @velocity_y *= friction
    end

    def damage_collision(damage)
      @current_hp -= damage
      @current_hp = 0 if @current_hp < 0
    end

    def accelerate(direction)
      angle = self.rotate * Math::PI / 180
      case direction
      when :forward
        @velocity_x -= Math.sin(-angle) * self.acceleration
        @velocity_y -= Math.cos(angle) * self.acceleration
      when :backward
        @velocity_x += Math.sin(-angle) * self.acceleration
        @velocity_y += Math.cos(angle) * self.acceleration
      when :left
        @velocity_y -= Math.sin(angle) * self.acceleration
        @velocity_x -= Math.cos(-angle) * self.acceleration
      when :right
        @velocity_y += Math.sin(angle) * self.acceleration
        @velocity_x += Math.cos(-angle) * self.acceleration
      else
        raise 'unsupported direction'
      end
    end
  end
end
