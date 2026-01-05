# frozen_string_literal: true

require_relative './empty_box'

module Core
  module GUI
    class Healthbar
      attr_reader :mobile
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
        @border = EmptyBox.new(x:, y:, width:, height:, thickness: 3, color: 'blue', z:)
        @health = Rectangle.new(x:, y:, width:, height:, color: bar_color, z: zlevel - 1)
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
          @health.width = width * health_percentage
          self.show
        end
      end

      private def border
        @border
      end

      private def refresh_fill_in_color
        @health.color = self.bar_color
      end

      def hide
        self.border.hide
        refresh_fill_in_color
      end

      def show
        self.border.show
        refresh_fill_in_color
      end

      private def bar_color
        return [0, 1.0, 0, 0] if mobile.nil?
        health_percentage = self.mobile.current_hp.to_f/self.mobile.max_hp

        r_value = 1.0 - health_percentage
        g_value = health_percentage
        [r_value, g_value, 0, 1]
      end

      def x=(value)
        dx = value - @top.x
        [@top, @bottom, @left, @right].each { |r| r.x += dx }
      end

      def y=(value)
        dy = value - @top.y
        [@top, @bottom, @left, @right].each { |r| r.y += dy }
      end

      def border_color=(val)
        self.border.color=val
      end
    end    
  end
end
