# frozen_string_literal: true

require 'forwardable'

module Movables
  module ScreenPositioning
    def self.included(base)
      base.extend Forwardable

      base.class_eval do
        # scope :disabled, -> { where(disabled: true) }
        def_delegator :image, :rotate
        def_delegator :image, :rotate=
        def_delegator :image, :remove
        def_delegator :engine, :zoomlevel
      end
    end

    def engine
      Core::Engine.instance
    end

    def x=(val)
      image.x = relative_x_pos
      @x = val
    end

    def y=(val)
      image.y = relative_y_pos
      @y = val
    end

    def relative_x_pos
      (x - engine.x_min) * zoomlevel
    end

    def relative_y_pos
      (y - engine.y_min) * zoomlevel
    end

    def update_positions
      image.y = relative_y_pos
      image.x = relative_x_pos
    end

    def x
      @x || 0
    end

    def y
      @y || 0
    end

    def width
      @width || 1
    end

    def height
      @height || 1
    end

    def visible_width
      width * zoomlevel
    end

    def visible_height
      height * zoomlevel
    end

    def update_size
      image.height = height * zoomlevel
      image.width = width * zoomlevel
    end
  end
end
