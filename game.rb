require 'ruby2d'
require_relative './core/engine'
require_relative './core/directory_includer'

extend Core::DirectoryIncluder

require_directory 'events'
require_directory 'movables'
require_directory 'db'

game = Core::Engine.instance
game.set_bounds(800, 600)
set(title: 'untitled sci-fi title', width: game.bounds[:width], height: game.bounds[:height])

on :key_down do |event|
  game.player.handle_key_down_input(event)
end

on :key_held do |event|
  game.player.handle_key_held_input(event)
end

on :mouse_down do |event|
  game.handle_mouse_click(event)
end

update do
  game.update
end

show