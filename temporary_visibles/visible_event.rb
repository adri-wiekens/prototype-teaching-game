require_relative '../movables/screen_positioning.rb'

module TemporaryVisibles
  class VisibleEvent
    attr_reader :mark_for_remove, :image
    include Movables::ScreenPositioning

    def_delegator :image, :play

    def initialize(animation_path, x, y, 
      width: 64,
      height:64,
      clip_width: 64, 
      clip_height: 64,
      time: 25,
      loop: false,
      z: 20)

      @x = x
      @y = y
      @width = width
      @height = height

      @image = Sprite.new(
        animation_path,
        x:, y:,
        width:,
        height:,
        clip_width:,
        clip_height:,
        time:,
        loop:,
        z:
       )
      update_size
      update_positions
    end

    def remove_me
      @mark_for_remove = true
    end
  end
end