# frozen_string_literal: true

require_relative './screen_positioning'

module Unmovables
  class Ground
    include Movables::ScreenPositioning

    attr_reader :velocity_x, :velocity_y, :rotation_speed, :acceleration, :friction_affected, :gravity_affected, :id,
                :mark_for_remove, :image
    
    private def screen_width
      engine.bounds[:width]
    end

    private def screen_height
      engine.bounds[:height]
    end

    def mob_db_get(id)
      Db::ResourceConnector.instance.get_mobile_properties(id)
    end

    def initialize(file_path, id:, x:, y:, width:, height:, **additional_parameters)
      @image = Ruby2D::Image.new(file_path, x:, y:, width:, height:, **additional_parameters)
      @mark_for_remove = false
      @x = x
      @y = y
      @width = width
      @height = height
      self.friction_affected = true
      self.gravity_affected = true
      @velocity_x = 0.0
      @velocity_y = 0.0
      @id = id

      update_attributes
    end

    def screen_x
      @image&.x
    end

    def screen_y
      @image&.y
    end

    def remove_me
      @mark_for_remove = true
      remove
    end

    def gravity_affected=(val)
      raise 'Only true or false!' unless [true, false].include?(val)

      @gravity_affected = val
    end

    def friction_affected=(val)
      raise 'Only true or false!' unless [true, false].include?(val)

      @friction_affected = val
    end

    def apply_gravity(gravity)
      return unless gravity_affected

      @velocity_y +=  gravity
    end

    def update_attributes
      @rotation_speed = mob_db_get(id)['rotation_speed']
      @acceleration = mob_db_get(id)['acceleration']
    end

    def rotate_to(direction)
      case direction
      when :left
        self.rotate -= rotation_speed * engine.delta_time
      when :right
        self.rotate += rotation_speed * engine.delta_time
      else
        raise 'unsupported direction'
      end
    end

    def update_position(friction)
      self.x += velocity_x
      self.y += velocity_y
      
      update_size

      return unless friction_affected

      @velocity_x *= friction
      @velocity_y *= friction
    end

    def damage_collision(damage)
      @current_hp -= damage
      @current_hp = 0 if @current_hp.negative?
    end

    def accelerate(direction)
      angle = self.rotate * Math::PI / 180
      case direction
      when :forward
        @velocity_x -= Math.sin(-angle) * acceleration * engine.delta_time
        @velocity_y -= Math.cos(angle) * acceleration * engine.delta_time
      when :backward
        @velocity_x += Math.sin(-angle) * acceleration * engine.delta_time
        @velocity_y += Math.cos(angle) * acceleration * engine.delta_time
      when :left
        @velocity_y -= Math.sin(angle) * acceleration * engine.delta_time
        @velocity_x -= Math.cos(-angle) * acceleration * engine.delta_time
      when :right
        @velocity_y += Math.sin(angle) * acceleration * engine.delta_time
        @velocity_x += Math.cos(-angle) * acceleration * engine.delta_time
      else
        raise 'unsupported direction'
      end
    end
  end
end
