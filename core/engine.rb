require 'singleton'
require_relative './directory_includer.rb'
require_relative '../events/key_binder.rb'
require_relative './gui.rb'

module Core
  class Engine
    include Singleton

    attr_reader :movables
    attr_reader :visible_events
    attr_reader :player
    attr_reader :bounds
    attr_reader :zoomlevel
    attr_reader :friction
    attr_reader :gravity
    attr_reader :interval_ticker
    attr_reader :clickables
    attr_reader :global_ticker

    def delta_time
      return 1 if @delta_time.nil?
      @delta_time.to_f * 60
    end

    def set_bounds(width, height)
      self.friction = 0.05
      self.gravity = 0.75
      self.interval_ticker= 0.3

      @bounds = { width: width, height: height }
      @movables ||= []
      @visible_events ||= []
      @clickables ||= []
      @last_time = 0.0
      @global_ticker = 0

      set_key_binder
      gui.set_all_elements

      @player = build_player
      @zoomlevel = 1.0

      self.movables << self.player
      self.clickables << self.player
    end

    private def gravity=(val)
      raise "invalid gravity value" if val < 0
      @gravity = val
    end

    private def interval_ticker=(val)
      raise "invalid ticker value" if val < 0
      @interval_tickers = val
    end

    private def friction=(val)
      raise "invalid friction value" if val < 0 
      @friction = 1.to_f/(val+1)
    end

    private def set_key_binder
      Events::KeyBinder.instance.reload_key_bindings
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
      visible_events << explosion
    end

    def hit_targets(x, y)
      movables.each do |mov|
        if x > mov.x && x < mov.x + mov.width && y > mov.y && y < mov.y + mov.height
          mov.damage_collision(50) if mov.is_a?(Movables::Mobile)
        end
      end
    end

    def update
      current_time = Time.now
      @delta_time = current_time - @last_time

      movables.each do |mov|
        mov.update_position(friction)
        mov.update_attributes
        mov.apply_gravity(self.gravity)
      end
      
      visible_events.each do |vis|
        vis.play do
          vis.remove_me
        end
      end

      visible_events.each do | vis | 
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

    def handle_mouse_click(event)
      clickables.each do |click_me|
        if event.button == :left &&
          event.x.between?(click_me.x, click_me.x + click_me.width) &&
          event.y.between?(click_me.y, click_me.y + click_me.height)
          gui.select(click_me)
          return click_me
        end
      end
      gui.deselect
    end
  end
end
