require "io/console"

class Grid
  DEFAULT_COLOR = 49
  MOUSE_REGEX = /\e\[<0;(\d+);(\d+)m/
  attr_reader :state_arr

  def initialize(width, height, origin)
    @width = width
    @height = height
    @origin = origin
    @state_arr = Array.new(@height) {Array.new(@width) {{text:' ', color: DEFAULT_COLOR}}}
  end

  def render(pattern = nil, color = nil)
    patterns(pattern,color)
    origin_x = @origin[0]
    origin_y = @origin[1]

    @state_arr.each_with_index do |row,i|
      change_cursor_position(origin_y + i,origin_x)
      row.each_with_index do |cell,j|
        yield(i,j,cell) if block_given?
        render_cell(cell[:color],cell[:text])
      end
    end
    print "\n"
  end

  def colors(color)
    case color
    when 'black'
      40
    when 'red'
      41
    when 'green'
      42
    when 'yellow'
      43
    when 'blue'
      44
    when 'magenta'
      45
    when 'cyan'
      46
    when 'white'
      47
    end
  end
  
  def get_mouse_input
    loop do
      enable_mouse_input
      buffer = ''
      mouse_input = ''
      STDIN.raw do |input|
        loop do
          buffer << input.getc
          if (match = buffer.match(MOUSE_REGEX))
            mouse_input = [match[2].to_i,match[1].to_i]
            break
          end
        end
      end
      disable_mouse_input
      coordinates = transform(mouse_input)
      return coordinates if coordinate_in_range(coordinates)
    end
  end 

  private

  def enable_mouse_input
    print "\e[?1000h" "\e[?1006h"
  end

  def disable_mouse_input
    print "\e[?1000l"
  end

  def change_cursor_position(y_axis,x_axis)
    print "\e[#{y_axis};#{x_axis}H"
  end

  def render_cell(color,text)
    print "\e[#{color}m #{text} \e[0m"
  end

  def coordinate_in_range(coordinates)
    y_axis = coordinates[0]
    x_axis = coordinates[1]
    
    x_axis.between?(0,@width - 1) && y_axis.between?(0,@height - 1)
  end

  def transform(coordinates)
    y_axis = coordinates[0]
    x_axis = coordinates[1]

    origin_x = @origin[0]
    origin_y = @origin[1]

    x_offset = (x_axis - origin_x) / 3

    y_offset = y_axis - origin_y
    
    [y_offset,x_offset]
  end

  def patterns(pattern,color)
    case pattern
    when 'checkered'
      @state_arr.each_with_index do |row,i|
        row.each_with_index do |cell,j|
          if j.even? && i.even? || j.odd? && i.odd?
            cell[:color] = colors(color[0])
          else
            cell[:color] = colors(color[1])
          end
        end
      end
    end
  end
end