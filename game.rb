# frozen_string_literal: true

require 'ruby2d'
require_relative './core/engine'
require_relative './core/directory_includer'
require_relative './core/background_workers/background_worker_manager'

extend Core::DirectoryIncluder

require_directory 'events'
require_directory 'movables'
require_directory 'db'
require_directory 'core'

Core::GameSettings.instance.reload_settings

def settings
  Core::GameSettings.instance
end

def threadpool
  Core::BackgroundWorkers::BackgroundWorkerManager.instance
end

game = Core::Engine.instance

world = Unmovables::World.instance

world.world = 'world_1'

threadpool.build_connection

threadpool.add_worker(:ticker)
threadpool.add_worker(:connection)

game.set_bounds(settings.resolution[:width], settings.resolution[:height])
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

on :mouse_scroll do |event|
  game.handle_mouse_scroll(event, Window.mouse_x, Window.mouse_y)
end

update do
  game.update
end

show
