require "io/console"

class Grid
  DEFAULT_COLOR = 49

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
      print "\e[#{origin_y + i};#{origin_x}H"
      row.each_with_index do |cell,j|
        yield(i,j,cell) if block_given?
        print "\e[#{cell[:color]}m #{cell[:text]} \e[0m"
      end
    end
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
  
  def get_state
    coordinates = get_mouse_input
    row = coordinates[0]
    column = coordinates[1]

    @state_arr[row][column]
  end

  private
  
  def get_mouse_input
    print "\e[?1000h" "\e[?1006h"
    mouse_input = ''
    STDIN.raw do 
      until mouse_input.include?('m')
        mouse_input << STDIN.getch
      end
    end
    print "\e[?1000l"
    coordinates = create_window(parse_input(mouse_input))
    coordinates
  end 

  def parse_input(event)
    event = event.split(';')
    x_axis = event[1]
    y_axis = event[2]
    [y_axis.to_i,x_axis.to_i] 
  end

  def create_window(coordinates)
    coordinates = transform(coordinates)
    until coordinate_in_range(coordinates)
      coordinates = get_mouse_input
    end
    coordinates
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

    x_offset = x_axis - origin_x
    
    case x_offset % 3
    when 0
      x_offset = x_offset/3
    when 1
      x_offset = (x_offset - 1)/3
    when 2
      x_offset = (x_offset - 2)/3
    end

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