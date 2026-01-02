module Core
  class Gui
    include Singleton

    attr_reader :player_coordinates
    attr_reader :z_level
    attr_reader :healthbar

    def set_all_elements
      @z_level = 10000
      @player_coordinates = build_coordinate_text
      @healthbar = build_health_bar
    end

    def build_coordinate_text
      Text.new(
        player_coordinates,
        x: 20,
        y: 20,
        size: 30,
        color: 'white',
        z: self.z_level,
      )
    end

    def set_health
      health_percentage = engine.player&.current_hp.to_f/engine.player&.max_hp
      healthbar.width = health_bar_width * health_percentage
    end

    def screen_width
      engine.bounds[:width]
    end

    def screen_height
      engine.bounds[:height]
    end

    def build_outline
      width = screen_width/10
      height = screen_height/15
    end

    def health_bar_width
      screen_width/8
    end

    def build_health_bar
      width = health_bar_width
      height = screen_height/15
      UnfilledRectangle.new(x: screen_width*4/5, y: screen_height/15, thickness: 3, width: width, height: height, color: 'blue', z: z_level+1)
      Rectangle.new(x: screen_width*4/5, y: screen_height/15, width: width, height: height, color: 'green', z: z_level)
    end

    def player_coordinates_text
      "Player_location: #{engine.player&.x&.round(2)}, #{engine.player&.y&.round(2)}"
    end

    def show_coordinates(enabled)
      if(enabled)
        self.player_coordinates.opacity = 1
      else
        self.player_coordinates.opacity = 0
      end
    end

    def refresh
      self.player_coordinates.text = player_coordinates_text
      set_health
    end

    def engine
      Core::Engine.instance
    end

    class UnfilledRectangle
      def initialize(x:, y:, width:, height:, thickness: 2, color: 'white', z: 0)
        @top = Rectangle.new(x: x, y: y, width:, height: thickness, color: color, z: z)
        @bottom = Rectangle.new(x: x, y: y + height - thickness, width:, height: thickness, color: color, z: z)
        @left = Rectangle.new(x: x, y: y, width: thickness, height:, color: color, z: z)
        @right = Rectangle.new(x: x + width - thickness, y: y, width: thickness, height:, color: color, z: z)
      end

      def x=(value)
        dx = value - @top.x
        [@top, @bottom, @left, @right].each { |r| r.x += dx }
      end

      def y=(value)
        dy = value - @top.y
        [@top, @bottom, @left, @right].each { |r| r.y += dy }
      end
    end
  end
end
