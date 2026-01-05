# frozen_string_literal: true

module Core
  module GUI
    class EmptyBox
      attr_reader :width
      attr_reader :height
      attr_reader :x
      attr_reader :y
      attr_reader :z
      attr_reader :thickness
      attr_reader :color

      def initialize(x: 0, y: 0, width: 100, height: 100, color: [1.0, 1.0, 1.0, 1.0], thickness: 3, z: 1000)
        @width = width
        @height = height
        @x = x
        @y = y
        @z = z
        @color = color_from_input([0.0, 0.0, 0.0, 1.0], color)
        @thickness = thickness

        border << horizontal_line
        border << horizontal_line
        border << vertical_line
        border << vertical_line

        border[1].y += height
        border[1].width += thickness
        border[3].x += width

        refresh_color
      end

      def hide
        @color[3] = 0.0
        refresh_color
      end

      def show
        @color[3] = 1.0        
        refresh_color
      end

      def x=(value)
        dx = value - @top.x
        [@top, @bottom, @left, @right].each { |r| r.x += dx }
      end

      def y=(value)
        dy = value - @top.y
        [@top, @bottom, @left, @right].each { |r| r.y += dy }
      end

      def color=(val)
        @color = color_from_input(@color, val)
        refresh_color
      end

      private def horizontal_line
        Rectangle.new(x:, y:, width:, height: thickness, color:, z:)
      end

      private def vertical_line
        Rectangle.new(x:, y:, width:thickness, height:, color:, z:)
      end

      private def refresh_color
        self.border.each {|line| line.color = self.color }
      end

      private def color_from_input(old_color, val)
        opacity = old_color[3]
        temp_color = Ruby2D::Color.new(val) # parse a color but keep the opacity as it was
        [temp_color.r, temp_color.g, temp_color.b, opacity]
      end

      private def border
        @border ||= []
      end
    end    
  end
end
