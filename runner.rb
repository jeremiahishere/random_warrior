require './make_levels'
require 'fileutils'

minimum_level_size = 10
number_of_levels = 10
spaces_with_things = 0.35
seed = 1000

FileUtils.rm_rf(seed.to_s)

ml = MakeLevels.new(minimum_level_size, number_of_levels, spaces_with_things, seed)
ml.generate_levels
