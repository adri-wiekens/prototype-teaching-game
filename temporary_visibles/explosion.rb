# frozen_string_literal: true

require_relative './visible_event'

module TemporaryVisibles
  class Explosion < VisibleEvent
    def initialize(x, y)
      super('assets/images/explosion3.png', x, y)
    end
  end
end
