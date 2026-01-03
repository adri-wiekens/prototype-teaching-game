require_relative './GUI/selection_render.rb'

module Core
  class Gui
    include Singleton

    attr_reader :debug_info
    attr_reader :show_debug_info
    attr_reader :z_level
    attr_reader :healthbar
    attr_reader :health_outline
    attr_reader :target_healthbar
    attr_reader :target_outline
    attr_reader :selected
    attr_reader :selection_render

    def set_all_elements
      @z_level = 1000
      @show_debug_info = true
      @debug_info = build_debug_info
      @selection_render = GUI::SelectionRender.new
      @health_outline, @healthbar = build_health_bar
      @target_outline, @target_healthbar = build_health_bar(1)
    end

    def build_debug_info
      [build_coordinate_text, build_delta_time_info]
    end

    def build_coordinate_text
      Text.new(
        player_coordinates_text,
        x: 20,
        y: 20,
        size: 30,
        color: 'white',
        z: self.z_level,
      )
    end

    def build_delta_time_info
      Text.new(
        delta_time_text,
        x: 20,
        y: 80,
        size: 30,
        color: 'white',
        z: self.z_level
      )
    end

    def delta_time_text
      "Delta T => #{engine.delta_time}"
    end

    def set_health(mobile)
      return if mobile.nil?
      health_percentage = mobile.current_hp.to_f/mobile.max_hp
      
      healthbar.width = health_bar_width * health_percentage if mobile == engine.player
      target_healthbar.width = health_bar_width * health_percentage if mobile == selected
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

    def build_health_bar(index = 0)
      y = screen_height/15
      y += index*2*screen_height/15
      width = health_bar_width
      height = screen_height/15
      [
        UnfilledRectangle.new(x: screen_width*4/5, y:, thickness: 3, width: width, height: height, color: 'blue', z: z_level+1),
        Rectangle.new(x: screen_width*4/5, y:, width: width, height: height, color: 'green', z: z_level)
      ]
    end

    def player_coordinates_text
      "Player_location: #{engine.player&.x&.round(2)}, #{engine.player&.y&.round(2)}"
    end

    def show_debug_text(enabled)
      @show_debug_info = enabled
      self.debug_info.each { |info| info.color.a = enabled ? 1 : 0 }
    end

    def toggle_debug_info
      show_debug_text(!self.show_debug_info)
    end

    def update_debug_info
      self.debug_info[0].text = player_coordinates_text
      self.debug_info[1].text = delta_time_text
    end

    def refresh
      update_debug_info
      set_health(engine.player)
      if self.selected.nil?
        self.target_healthbar.color = [1.0, 0.0, 0.0, 0.0]
        self.target_outline.color = [0.0, 0.0, 1.0, 0.0]
      else
        set_health(self.selected)
        self.target_healthbar.color = [1.0, 0.0, 0.0, 1.0]
        self.target_outline.color = [0.0, 0.0, 1.0, 1.0]
      end

      show_selection
    end

    def show_selection
      selected.nil? ? self.selection_render.deselect : self.selection_render.select(selected)
    end

    def engine
      Core::Engine.instance
    end

    def deselect
      @selected = nil
    end

    def select(selectable)
      @selected = selectable
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

      def color=(val)
        [@top, @bottom, @left, @right].each { |r| r.color=val }
      end
    end
  end
end
