# frozen_string_literal: true

module Core
  module GUI
    class Minimap
      attr_reader :mobiles
      attr_reader :zlevel
      attr_reader :width
      attr_reader :height
      attr_reader :x
      attr_reader :y

      def initialize(mobile, x: 0, y: 0, width: 100, height: 100, z: 1000)
        @zlevel = z
        @width = width
        @height = height
        @x = x
        @y = y

        border << horizontal_line
        border << horizontal_line
        border << vertical_line
        border << vertical_line

        border[1].y += height
        border[3].x += width

        @health_fill_in = Rectangle.new(x:, y:, width:, height:, color: bar_color, z: zlevel - 1)
      end

      def mobile=(mobile)
        @mobile = mobile
        update
      end

      def update
        if self.mobile.nil?
          self.hide
        else
          health_percentage = self.mobile.current_hp.to_f/self.mobile.max_hp
          @health_fill_in.width = width * health_percentage
          self.show
        end
      end

      private def refresh_border_color
        self.border.each {|line| line.color = self.border_color }
      end

      private def refresh_fill_in_color
        @health_fill_in.color = self.bar_color
      end

      def hide
        @border_color[3] = 0.0
        refresh_border_color
        refresh_fill_in_color
      end

      def show
        @border_color[3] = 1.0        
        refresh_border_color
        refresh_fill_in_color
      end

      private def horizontal_line
        Rectangle.new(x:, y:, width:, height: thickness, color: border_color, z: zlevel)
      end

      private def vertical_line
        Rectangle.new(x:, y:, width:thickness, height:, color: border_color, z: zlevel)
      end

      private def thickness
        @thickness ||= 3
      end

      private def color_from_string(old_color, val)
        opacity = old_color[3]
        temp_color = Ruby2D::Color.new(val) # parse a color but keep the opacity as it was
        [temp_color.r, temp_color.g, temp_color.b, opacity]
      end

      private def border_color
        @border_color ||= [0,0,1.0, 0]
      end

      private def bar_color
        return [0, 1.0, 0, 0] if mobile.nil?
        health_percentage = self.mobile.current_hp.to_f/self.mobile.max_hp

        r_value = 1.0 - health_percentage
        g_value = health_percentage
        [r_value, g_value, 0, 1]
      end

      private def border
        @border ||= []
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
        [@top, @bottom, @left, @right].each { |r| r.color=val }
      end
    end    
  end
end
