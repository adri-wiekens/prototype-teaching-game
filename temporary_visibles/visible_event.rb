module TemporaryVisibles
  class VisibleEvent < Sprite
    attr_reader :mark_for_remove

    def initialize(animation_path, x, y)
      super(
        animation_path,
        x:, y:,
        width: 64,
        height: 64,
        clip_width: 64,
        clip_height: 64,
        time: 25,
        loop: false,
        z: 20
       )
    end

    def remove_me
      @mark_for_remove = true
    end
  end
end