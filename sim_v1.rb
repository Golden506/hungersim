=begin
DEVLOG:
- set up survivor data type
- programmed movement patterns
- created coordinate map system
- generated example tributes
- created movement/encounter iteration
- fixed bug where encounters were mirrored
=end
class Survivor
  def initialize(strength, agility, intellect, divine_power)
    #static attributes
    @strength = strength
    @agility = agility
    @intellect = intellect
    @divine_power = divine_power
    #variable attributes
    @loc_x = 3
    @loc_y = 3
    @encountered = nil

  end
  def move
    #picks randomly which axis to move on and then in which direction
    #also sets the size of the map
    if rand(2) == 0
      unless @loc_x == 1 || @loc_x == 5
        rand(2) == 0 ? @loc_x += 1 : @loc_x -= 1
      else
        @loc_x == 1 ? @loc_x +=1 : @loc_x -= 1
      end
    else
      unless @loc_y == 1 || @loc_y == 5
        rand(2) == 0 ? @loc_y += 1 : @loc_y -= 1
      else
        @loc_y == 1 ? @loc_y +=1 : @loc_y -= 1
      end
    end
  end
  #static attributes
  attr_accessor :strength, :agility, :intellect, :divine_power
  #variable attributes
  attr_accessor :loc_x, :loc_y, :encountered
end

tributes = {"paul" => Survivor.new(5,5,8,0), "jonas" => Survivor.new(3,8,6,0)}

15.times do
  #moves each tribute, and logs new coordinates
  tributes.each do |key, tribute|
    tribute.encountered = nil
    tribute.move
    puts "x of #{key}: #{tribute.loc_x}"
    puts "y of #{key}: #{tribute.loc_y}"
    puts ""
  end
  #checks for encounters between two people
  tributes.each do |key1, tribute1|
    tributes.each do |key2, tribute2|
        if key2 != key1 && tribute2.loc_x == tribute1.loc_x && tribute2.loc_y == tribute1.loc_y
          break if tribute1.encountered == key2
          puts "#{key1} encounters #{key2}\n"
          tribute2.encountered = key1
        end
    end
  end
end


=begin
tributes = [wesley, maddie, nash, jack, aidan]

tributes[wesley] = Survivor.new(1, 3, 3, 1)
tributes[maddie] = Survivor.new(7, 4, 8, 2)
tributes[nash] = Survivor.new(3, 9, 5, 0)
tributes[jack] = Survivor.new(3, 3, 10, 0)
tributes[aidan] = Survivor.new(8, 1, 7, 10)
=end
