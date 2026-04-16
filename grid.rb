require "io/console"

class Grid
  RED = 41

  def initialize(width, height, origin)
    @width = width
    @height = height
    @origin = origin
    @state_arr = Array.new(@height) {Array.new(@width, 'X')}
  end

  def render
    origin_x = @origin[0]
    origin_y = @origin[1]
    print "\e[#{origin_y + 1};#{origin_x + 1}H"

    @state_arr.each_with_index do |row,i|
      row.each do |state|
        print "\e[41m #{state} \e[0m"
      end
      print "\n"
      print "\e[#{origin_y + 1 + i};#{origin_x + 1}H"
    end
  end

  def get_mouse_input
    print "\e[?1000h" "\e[?1006h"
    mouse_input = ''
    STDIN.raw do 
      until mouse_input.include?('m')
        mouse_input << STDIN.getch
      end
    end
    print "\e[?1000l"
    coordinates = parse_input(mouse_input)
    create_window(coordinates)
  end
  
  private

  def parse_input(event)
    event = event.split(';')
    x_axis = event[1]
    y_axis = event[2]
    [x_axis.to_i,y_axis.to_i] 
  end

  def create_window(coordinates)
    coordinates = transform(coordinates)
    until coordinate_in_range(coordinates)
      coordinates = get_mouse_input
    end
    coordinates
  end 

  def coordinate_in_range(coordinates)
    x_axis = coordinates[0]
    y_axis = coordinates[1]
    
    x_axis.between?(1,@width) && y_axis.between?(1,@height)
  end

  def transform(coordinates)
    x_axis = coordinates[0]
    y_axis = coordinates[1]

    origin_x = @origin[0]
    origin_y = @origin[1]

    x_offset = x_axis - origin_x
    y_offset = y_axis - origin_y

    [x_offset,y_offset]
  end

end

#mouse = Grid.new(3,1,[10,10]).get_mouse_input
grid = Grid.new(5,5,[10,10])
grid.render
p grid.get_mouse_input