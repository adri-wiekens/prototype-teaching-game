# frozen_string_literal: true

require 'singleton'
require_relative './directory_includer'
require_relative '../events/key_binder'
require_relative './gui'

module Core
  class Engine
    include Singleton

    attr_reader :player, :bounds, :zoomlevel, :friction, :gravity, :interval_ticker, :global_ticker, :ambiance, :x_min,
                :y_min, :pan_step_size

    def delta_time
      return 1 if @delta_time.nil?

      @delta_time.to_f * 60
    end

    def reset_position
      @zoomlevel = 1.0
      @y_min = 0
      @x_min = 0
    end

    def play_sound(sound_file)
      sound = Sound.new("assets/audio/effects/#{sound_file}")
      sounds << sound
      sound.play
    end

    def play_music(sound_file)
      @ambiance = Music.new("assets/audio/music/#{sound_file}.mp3")
      ambiance.loop
      ambiance.play
    end

    def x_min=(val)
      @x_min = if val < limits[:west]
                 limits[:west]
               elsif val > limits[:east] - screen_range_x
                 limits[:east] - screen_range_x
               else
                 val
               end
    end

    def y_min=(val)
      @y_min = if val < limits[:sky]
                 limits[:sky]
               elsif val > limits[:ground] - screen_range_y * 0.9
                 limits[:ground] - screen_range_y * 0.9
               else
                 val
               end
    end

    def pan(direction)
      step = pan_step_size / zoomlevel
      case direction
      when :up
        self.y_min = y_min - step
      when :down
        self.y_min = y_min + step
      when :left
        self.x_min = x_min - step
      when :right
        self.x_min = x_min + step
      end
    end

    def limits
      @limits ||= world.limits
    end

    def world
      Unmovables::World.current
    end

    def <<(val)
      movables << val if val.is_a?(Movables::Movable)
      visible_events << val if val.is_a?(TemporaryVisibles::VisibleEvent)
      clickables << val if val.respond_to?(:selectable) && val.selectable?
    end

    def set_bounds(width, height)
      self.friction = 0.05
      self.gravity = 0.75
      self.interval_ticker = 0.3

      @bounds = { width: width, height: height }

      @last_time = 0.0
      @global_ticker = 0
      @x_min = 0
      @y_min = 0
      @click_tolerance = 5
      @pan_step_size = 20

      set_key_binder
      gui.set_all_elements

      @player = build_player
      @zoomlevel = 1.0

      self << player
    end

    def keymap
      Events::KeyBinder.instance.key_bindings
    end

    def build_player
      ::Movables::Player.new
    end

    def explode(x, y)
      explosion = TemporaryVisibles::Explosion.new(x, y)
      hit_targets(x, y)
      self << explosion
    end

    def hit_targets(x, y)
      movables.each do |mov|
        if x > mov.x && x < mov.x + mov.width && y > mov.y && y < mov.y + mov.height && mov.is_a?(Movables::Mobile)
          mov.damage_collision(50)
        end
      end
    end

    def update
      current_time = Time.now
      @delta_time = current_time - @last_time

      unmovables.each(&:update_position)

      movables.each do |mov|
        mov.update_position(friction)
        mov.update_attributes
        mov.apply_gravity(gravity)
      end

      visible_events.each do |vis|
        vis.update_positions
        vis.play do
          vis.remove_me
        end

        vis.remove if vis.mark_for_remove
      end

      take_out_garbage
      gui.refresh

      @global_ticker += 1
      @last_time = current_time
    end

    def take_out_garbage
      movables.reject!(&:mark_for_remove)
      clickables.reject!(&:mark_for_remove)
      visible_events.reject!(&:mark_for_remove)
    end

    def gui
      Core::Gui.instance
    end

    def translate_click_event(x, y)
      {
        x: x_min + x / zoomlevel,
        y: y_min + y / zoomlevel
      }
    end

    def handle_mouse_click(event)
      translate_click_event(event.x, event.y)
      clickables.each do |click_me|
        next unless event.button == :left &&
                    event.x.between?(click_me.screen_x - click_tolerance,
                                     click_me.screen_x + click_me.visible_width + click_tolerance) &&
                    event.y.between?(click_me.screen_y - click_tolerance,
                                     click_me.screen_y + click_me.visible_height + click_tolerance)

        gui.select(click_me)
        return click_me
      end
      gui.deselect
    end

    def screen_range_x
      bounds[:width].to_f / zoomlevel
    end

    def screen_range_y
      bounds[:height].to_f / zoomlevel
    end

    def world_range_x
      limits = world.limits
      limits[:east] - limits[:west]
    end

    def world_range_y
      limits = world.limits
      limits[:ground] - limits[:sky]
    end

    def min_zoom
      max_zoom_x = bounds[:width].to_f / world_range_x
      max_zoom_y = bounds[:height].to_f / world_range_y

      max_zoom_x < max_zoom_y ? max_zoom_y : max_zoom_x
    end

    def max_zoom
      16
    end

    def handle_mouse_scroll(event, x, y)
      coor = translate_click_event(x, y)

      @zoomlevel *= 2**-event.delta_y

      @zoomlevel = max_zoom if @zoomlevel > max_zoom
      @zoomlevel = min_zoom if @zoomlevel < min_zoom

      if event.delta_y.positive?
        self.x_min -= screen_range_x / 4
        self.y_min -= screen_range_y / 4
      else
        self.x_min = (coor[:x] - screen_range_x / 2)
        self.y_min = (coor[:y] - screen_range_y / 2)
      end
    end

    private

    attr_reader :click_tolerance

    def movables
      @movables ||= []
    end

    def unmovables
      @unmovables ||= []
    end

    def clickables
      @clickables ||= []
    end

    def visible_events
      @visible_events ||= []
    end

    def sounds
      @sounds ||= []
    end

    def gravity=(val)
      raise 'invalid gravity value' if val.negative?

      @gravity = val
    end

    def interval_ticker=(val)
      raise 'invalid ticker value' if val.negative?

      @interval_tickers = val
    end

    def friction=(val)
      raise 'invalid friction value' if val.negative?

      @friction = 1.to_f / (val + 1)
    end

    def set_key_binder
      Events::KeyBinder.instance.reload_key_bindings
    end
  end
end
