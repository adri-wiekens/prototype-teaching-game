# frozen_string_literal: true

module Core
  module SoundPlayer
    def play_sound(file_path)
      Core::Engine.instance.play_sound(file_path)
    end

    def play_music(file_path)
      Core::Engine.instance.play_music(file_path)
    end

    def fade_music
      Core::Engine.instance.fade_music(2000)
    end
  end
end
