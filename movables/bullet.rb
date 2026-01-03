require 'forwardable'

require_relative './projectile.rb'

module Movables
  class Bullet < Projectile
    extend Forwardable

    attr_reader :timer
    attr_reader :shoot_time

    def initialize(mobile:, **additional_parameters)
      file_path = 'assets/images/bullet.png'
      @timer = 60
      @shoot_time = engine.global_ticker
      super(file_path,
        rotation: mobile.rotate, 
        start_velocity_x: mobile.velocity_x,
        start_velocity_y: mobile.velocity_y,
        x: mobile.x,
        y: mobile.y,
        width: 10,
        height: 30,
        id: 'bullet', **additional_parameters)
    end

    def update_position(friction)
      super
      explode if engine.global_ticker > self.shoot_time + self.timer
    end
  end
end
