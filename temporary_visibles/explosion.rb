require_relative './visible_event.rb'

module TemporaryVisibles
  class Explosion < VisibleEvent
    def initialize(x, y)
      super('assets/images/explosion3.png', x, y)
    end
  end
end