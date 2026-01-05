module Core
  module GUI
    class SelectionRender
      attr_reader :min_selection_size
      attr_reader :lines
      attr_reader :thickness
      attr_reader :z_level
      attr_reader :color
      attr_reader :selectable
      
      def zoomlevel
        engine.zoomlevel
      end

      def engine
        Core::Engine.instance
      end

      def initialize
        @min_selection_size ||= 10
        @color = [1.0, 1.0, 1.0, 0.0]
        @z_level = 2000
        @thickness = 3
      
        @toplefttop = horizontal_line
        @topleftleft = vertical_line
        
        @toprighttop = horizontal_line
        @toprightright = vertical_line

        @bottomleftbottom = horizontal_line
        @bottomleftleft = vertical_line

        @bottomrightbottom = horizontal_line
        @bottomrightright = vertical_line

        @lines = [@toplefttop, @topleftleft, @toprighttop, @toprightright, @bottomleftbottom, @bottomleftleft, @bottomrightbottom, @bottomrightright]
      end

      private def vertical_line
        Rectangle.new(x: 0, y: 0, width:thickness, height: min_selection_size, color: color, z: self.z_level)
      end

      private def horizontal_line
        Rectangle.new(x: 0, y: 0, width: min_selection_size, height: thickness, color: color, z:self.z_level)
      end

      def select(selectable)
        @selectable = selectable
        self.color[3] = 1.0
        resize
        set_colors
      end

      def deselect
        @selectable = nil
        self.color[3] = 0.0
        set_colors
      end

      def color=(val)
        opacity = self.color[3]
        temp_color = Ruby2D::Color.new(val) # parse a color but keep the opacity as it was
        @color = [temp_color.r, temp_color.g, temp_color.b, opacity]
      end

      private def set_colors
        lines.each { |line| line.color = self.color }
      end

      def relative_x_pos
        (selectable.x - engine.x_min) * zoomlevel
      end

      def relative_y_pos
        (selectable.y - engine.y_min) * zoomlevel
      end

      private def resize
        top = relative_y_pos - min_selection_size
        left = relative_x_pos - min_selection_size
        right = relative_x_pos + selectable.visible_width + min_selection_size
        bottom = relative_y_pos + min_selection_size + selectable.visible_height

        corner_size = selectable.width > selectable.height ? selectable.width * zoomlevel : selectable.height * zoomlevel
        corner_size = corner_size / 3.0
        corner_size = min_selection_size if corner_size < min_selection_size

        set_top_left(top:, left:, corner_size:)
        set_top_right(top:, right:, corner_size:)
        set_bottom_left(bottom:, left:, corner_size:)
        set_bottom_right(bottom:, right:, corner_size:)        
      end

      private def set_top_left(top:, left:, corner_size:)
        # top left corner
        @toplefttop.y = top
        @topleftleft.y= top
        @toplefttop.x = left
        @topleftleft.x= left

        @toplefttop.width = corner_size
        @topleftleft.height = corner_size
      end

      private def set_top_right(top:, right:, corner_size:)
        # top right corner
        @toprighttop.y = top
        @toprightright.y= top
        @toprighttop.x = right - corner_size
        @toprightright.x= right

        @toprighttop.width = corner_size
        @toprightright.height = corner_size        
      end

      private def set_bottom_left(bottom:, left:, corner_size:)
        #bottom left corner
        @bottomleftbottom.y = bottom
        @bottomleftleft.y= bottom - corner_size
        @bottomleftbottom.x = left
        @bottomleftleft.x= left

        @bottomleftbottom.width = corner_size
        @bottomleftleft.height = corner_size
      end

      private def set_bottom_right(bottom:, right:, corner_size:)
        #bottom right corner
        @bottomrightbottom.y = bottom
        @bottomrightright.y= bottom - corner_size
        @bottomrightbottom.x = right - corner_size
        @bottomrightright.x= right

        @bottomrightbottom.width = corner_size
        @bottomrightright.height = corner_size
      end      
    end
  end
end
