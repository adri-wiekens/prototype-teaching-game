require_relative './GUI/selection_render.rb'
require_relative './GUI/healthbar.rb'

module Core
  class Gui
    include Singleton

    attr_reader :debug_info
    attr_reader :show_debug_info
    attr_reader :z_level
    attr_reader :healthbar
    attr_reader :target_healthbar    
    attr_reader :selected
    attr_reader :selection_render

    def set_all_elements
      @z_level = 1000
      @show_debug_info = true
      @debug_info = build_debug_info
      @selection_render = GUI::SelectionRender.new
      @healthbar = build_health_bar(engine.player)
      @target_healthbar = build_health_bar(nil, 1)
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

    def build_health_bar(mobile, index = 0)
      x = screen_width*4/5
      y = screen_height/15
      y += index*2*screen_height/15
      width = health_bar_width
      height = screen_height/15
      
      Core::GUI::Healthbar.new(mobile, x:, y:, width:, height:)
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
      healthbar.mobile = engine.player if healthbar.mobile.nil?
      healthbar.update
      target_healthbar.update

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
      target_healthbar.mobile = self.selected
    end

    def select(selectable)
      @target_healthbar.mobile = selectable
      @selected = selectable
    end
  end
end
