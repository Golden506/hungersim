=begin
DEVLOG:
- added more tributes
- added stamina system
- added victory condition
- developed encounter system:
  - each tribute now chooses method based off of stats
  - encounter will have outcome based off of stat comparisons with random modifier
  - different methods(fight, flee, negotiate) result in different outcomes
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
    @stamina = 30
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
  attr_accessor :loc_x, :loc_y, :encountered, :stamina
end

tributes = {"paul" => Survivor.new(5,5,8,0), "jonas" => Survivor.new(3,8,6,0), "maddie" => Survivor.new(7, 4, 8, 2),
"nash" => Survivor.new(3, 9, 5, 0), "noah" => Survivor.new(6, 8, 2, 0), "sam" => Survivor.new(4, 6, 5, 0), "stam" => Survivor.new(8, 3, 5, 0),
"jack" => Survivor.new(3, 3, 10, 0), "aidan" => Survivor.new(8, 2, 7, 10)}

100.times do
  #moves each tribute, lowers stamina, and logs new coordinates
  break puts "#{tributes.keys} is victorious" if tributes.length == 1
  tributes.each do |key, tribute|
    tribute.encountered = nil
    tribute.move
    tribute.stamina -= 1
    if tribute.stamina < 1
      puts "#{key} collapses in exhaustion and dies slowly."
      tributes.delete(key)
    end
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

          #decides whether tribute1 will fight, flee, or negotiate based on their stats
          #(uses a marble bag method)
          statmax = tribute1.strength + tribute1.agility + tribute1.intellect
          case
          when rand(statmax) < tribute1.strength
            method1 = [tribute1.strength, 0]
          when rand(statmax) > tribute1.strength + tribute1.agility
            method1 = [tribute1.agility, 1]
          else
            method1 = [tribute1.intellect, 2]
          end

          #same but for tribute2
          statmax = tribute2.strength + tribute2.agility + tribute2.intellect
          case
          when rand(statmax) < tribute2.strength
            method2 = [tribute2.strength, 0]
          when rand(statmax) > tribute2.strength + tribute2.agility
            method2 = [tribute2.agility, 1]
          else
            method2 = [tribute2.intellect, 2]
          end

          #stat comparisons + rng to determine encounter outcome
          if (method1[0] + rand(5)) > (method2[0] + rand(5))
            case
            when method1[1] == 0
              puts "#{key1} attacks and kills #{key2}"
              tribute1.stamina -= 1
              tributes.delete(key2)
            when method1[1] == 1
              puts "#{key1} flees"
              tribute1.stamina -= 2
            when method1[1] == 2
              puts "#{key1} convinces #{key2} to provide assistance"
              tribute1.stamina += 4
              tribute2.stamina -= 2
            end
          else
            case
            when method2[1] == 0
              puts "#{key2} attacks and kills #{key1}"
              tribute2.stamina -= 1
              tributes.delete(key1)
            when method2[1] == 1
              puts "#{key2} flees"
              tribute2.stamina -= 2
            when method2[1] == 2
              puts "#{key2} convinces #{key1} to provide assistance"
              tribute2.stamina += 4
              tribute1.stamina -= 2
            end
          end
        end
    end
  end
end
