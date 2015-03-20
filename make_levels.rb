require 'fileutils'

class MakeLevels

  def initialize(minimum_width, number_of_levels, obj_percentage, seed)
    @minimum_width = minimum_width
    @levels = number_of_levels
    @obj_percentage = obj_percentage
    @seed = seed

    @randomizer = Random.new(@seed)
  end  

  def generate_levels
    FileUtils.mkdir(@seed.to_s)

    @levels.times do |i|
      level_size = @minimum_width + i
      level = generate_level(level_size)
      filename = "level_#{level_size.to_s.rjust(3, '0')}.rb"

      puts "Generating level #{filename}"
      puts level.to_file

      File.open(File.join(".", @seed.to_s, filename), 'w') do |f|
        f.write(level.to_file)
      end
    end
  end

  def generate_level(size)
    level = Level.new(size, @randomizer)

    level.add_player
    level.add_stairs

    obstacles = 2
    while obstacles < size * @obj_percentage
      level.add_obstacle
      obstacles += 1
    end

    level
  end

  class Level
    EMPTY = ' '
    STAIRS = '>'
    PLAYER = '@'

    ARCHER = 'a'
    CAPTIVE = 'C'
    SLUDGE = 's'
    THICK_SLUDGE = 'S'
    WIZARD = 'w'

    def initialize(size, randomizer)
      @size = size
      @randomizer = randomizer

      @level = []
      @size.times { @level << EMPTY }

      @player_space = nil
      @stairs_space = nil
    end

    def to_file
      output = "#  #{'-' * @size}
# |#{@level.join}|
#  #{'-' * @size}

description \"This level was randomly generated.\"
tip \"No tip for you.\"
clue\"No hint for you.\"

time_bonus #{@size}
ace_score #{@size * 5}
size #{@size}, 1
stairs #{@stairs_space}, 0

warrior #{@player_space}, 0, :east

"
      @level.each_with_index do |space, index|
        if obstacles.include?(space)
          output += "unit #{long_name(space)}, #{index}, 0, #{obstacle_direction(index)}\n"
        end
      end

      output
    end

    # can only be called once
    def add_player
      if !@player_space
        space = find_free_space
        @level[space] = PLAYER
        @player_space = space
      end
    end

    # can only be called once
    def add_stairs
      if !@stairs_space
        space = find_free_space
        @level[space] = STAIRS
        @stairs_space = space
      end
    end

    def add_obstacle
      obstacle = obstacles[@randomizer.rand(obstacles.count)]
      @level[find_free_space] = obstacle
    end

    protected

    def find_free_space
      while true
        space = @randomizer.rand(@size)
        if @level[space] == EMPTY
          return space
        end
      end
    end

    def obstacles
      @obstacles ||= [ ARCHER, CAPTIVE, SLUDGE, THICK_SLUDGE, WIZARD ]
    end

    # quality planning right here
    def long_name(short_name)
      case short_name
      when ARCHER
        ':archer'
      when CAPTIVE
        ':captive'
      when SLUDGE
        ':sludge'
      when THICK_SLUDGE
        ':thick_sludge'
      when WIZARD
        ':wizard'
      end
    end

    def obstacle_direction(index)
      if index > @player_space
        ':west'
      else
        ':east'
      end
    end
  end
end
