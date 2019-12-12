=begin
DEVLOG:
- added Ruby2D graphical interface
- added YAML save/load system
- hopelessly butchered indentation
=end

require 'yaml'
require 'ruby2d'

#map limits
$max_x = 5
$max_y = 5

class Survivor
  def initialize(strength, agility, intellect, divine_power, aggression, color)
    #static attributes
    @strength = strength
    @agility = agility
    @intellect = intellect
    @divine_power = divine_power
    @aggression = aggression
    @color = color
    #variable attributes
    @loc_x = 3
    @loc_y = 3
    @stamina = 30
    @encountered = nil
    @ally = nil
    @inv = [["their bare hands", 0, "attacks"], [nil, nil]]
    @damage = 0
    @shared = nil
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
  attr_accessor :strength, :agility, :intellect, :divine_power, :aggression, :color
  #variable attributes
  attr_accessor :loc_x, :loc_y, :encountered, :stamina, :ally, :inv, :damage, :shared
end

#seed to use
#srand(1111)

=begin
tributes = {"paul" => Survivor.new(6,6,5,0,0, 'gray'), "maddie" => Survivor.new(7, 4, 8, 0, -2, '#9800FE'),
"nash" => Survivor.new(3, 9, 5, 0, -1, 'orange'), "noah" => Survivor.new(6, 8, 2, 0, -1, 'yellow'), "sam" => Survivor.new(4, 6, 5, 0, -2, 'blue'),
}
=end

loadvar = YAML.load_file('load.yml')
tributes = Hash.new
loadvar.each do |key, value|
  tributes[key] = Survivor.new(value[0], value[1], value[2], value[3], value[4], value[5])
end

#x_pixel = 73 + (x-1) * 79
#y_pixel = 64 + (y-1) * 79


tribnum = tributes.length
dead = nil

set title: "PPHS Hunger Games", background: "white", height: 480, width: 1000

grid = Image.new('grid.png', x: 50, y: 40, width: 400, height: 400)
backing = Rectangle.new(width: 450, height: 400, x: 500, y: 40, color: '#e6e6e6')

markers = Hash.new
steps = Text.new("")
entries = Array.new

tributes.each do |key, tribute|
  markers[key] = Square.new(size: 40, x: 231, y: 222, color: tribute.color, z: 99)
end

i = -3
j = 0

entry = ""

update do
    i += 1
    puts ""
    sleep(1.5)
    next unless i >= 0
    steps.remove
    steps = Text.new("Step #: #{i}", font: 'SLC_.ttf', size: 20, color: 'black', z: 99, x: 675 , y: 55)
    queue = 0
    entry = []
    #moves each tribute, lowers stamina, and logs new coordinates
    if tributes.length == 1
      entry[queue] = "#{tributes.keys} is victorious"
      queue += 1
      temp = tributes.keys
      close
    end
    tributes.each do |key, tribute|
      tribute.encountered = nil
      tribute.move
      if tribute.shared == 'left'
        markers[key].size = 40
	markers[key].x += 15
	markers[key].y += 15
      elsif tribute.shared == 'right'
	markers[key].size = 40
	markers[key].x -= 15
	markers[key].y += 15
      end
      tribute.shared = nil
      markers[key].x = 73 + (tribute.loc_x-1) * 79
      markers[key].y = 64 + (tribute.loc_y-1) * 79
      tribute.stamina -= 1
      if tribute.stamina < 1
        entry[queue] = "#{key} collapses in exhaustion and dies slowly."
        queue += 1
        tributes.delete(key)
        markers[key].remove
        tribute.ally.ally = nil unless tribute.ally == nil
      elsif tribute.damage > 0 && tribute.inv[1][0] == "medical supplies"
        tribute.inv[1] = [nil, 0]
        tribute.stamina += 10
        tribute.damage = 0
        entry[queue] = "#{key} uses medical supplies"
        queue += 1
      end
      if tribute.damage > 1
        entry[queue] = "#{key} dies"
        queue += 1
        tributes.delete(key)
	markers[key].remove
        tribute.ally.ally = nil unless tribute.ally == nil
        break
      end
      #1/3 chance of random encounter
      if rand(3) == 0
        case
        when rand(10) == 0 || rand(10) == 1
          tribute.stamina += 3
          entry[queue] = "#{key} finds a source of fresh water"
          queue += 1
        when rand(10) == 2 || rand(10) == 3
          entry[queue] = "#{key} eats some wild greens"
          queue += 1
          rand(2) == 0 ? tribute.stamina += 3 : tribute.stamina -= 5
        when rand(10) == 4 || rand(10) == 8
          if tribute.agility + rand(2) + tribute.divine_power > 6
            entry[queue] = "#{key} slips but catches themself"
            queue += 1
            tribute.stamina -= 1
          else
            entry[queue] = "#{key} slips and is injured"
            queue += 1
            tribute.damage += 1
          end
        when rand(10) == 5 || rand(10) == 6
          case
          when rand(7) == 0 || rand(7) == 1 && tribute.inv[0][1] < 1
            entry[queue] = "#{key} is sent a shank"
            queue += 1
            tribute.inv[0] = ["a shank", 1, "stabs"]
          when rand(7) == 2 || rand(7) == 3 && tribute.inv[1]
            entry[queue] = "#{key} is sent some medical supplies"
            queue += 1
            tribute.inv[1] = ["medical supplies", 10]
          when rand(7) == 5 && tribute.inv[0][1] < 3
            entry[queue] = "#{key} is sent a tomahawk"
            queue += 1
            tribute.inv[0] = ["a tomahawk", 3, "attacks"]
          when rand(7) == 6 && tribute.inv[0][1] < 3
            entry[queue] = "#{key} is sent a broadsword"
            queue += 1
            tribute.inv[0] = ["a broadsword", 5, "slices"]
          end
        when rand(10) == 7
          unless tribute.intellect + rand(2) + tribute.divine_power > 7
            entry[queue] = "#{key} falls into a trap and dies."
            queue += 1
            tributes.delete(key)
	    markers[key].remove
            tribute.ally.ally = nil unless tribute.ally == nil
          end
        end
      end
    end

    #checks for encounters between two people
    tributes.each do |key1, tribute1|
      unless dead == key1
        tributes.each do |key2, tribute2|
            if key2 != key1 && tribute2.loc_x == tribute1.loc_x && tribute2.loc_y == tribute1.loc_y
              unless dead == key2 || dead == key1
                break if tribute1.encountered == key2
                entry[queue] = "#{key1} encounters #{key2}"
                queue += 1
                tribute2.encountered = key1

		#makes markers share space
		tribute1.shared = 'left'
		tribute2.shared = 'right'

		markers[key1].size -= 15
		markers[key1].x -= 8
		markers[key1].y += 3

		markers[key2].size -= 15
		markers[key2].x += 22
		markers[key2].y += 3

                #alliance encounters
                if tribute1.ally == tribute2
                  if tributes.length == 2 || rand(10) == 0
                    entry[queue] = "#{key1} and #{key2} break their alliance"
                    queue += 1
                    tribute1.ally = nil
                    tribute2.ally = nil
                  else
                    entry[queue] = "#{key1} encounters their ally #{key2}"
                    queue += 1
                    tribute1.stamina += 3
                    tribute2.stamina += 3
                    if tribute1.damage == 1 && tribute2.inv[1][0] == "medical supplies"
                      entry[queue] = "#{key2} shares medical supplies with #{key1}"
                      queue += 1
                      tribute1.damage = 0
                      tribute1.stamina += 5
                      tribute2.inv[1] = [nil, 0]
                    elsif tribute2.damage == 1 && tribute1.inv[1][0] == "medical supplies"
                      entry[queue] = "#{key1} shares medical supplies with #{key2}"
                      queue += 1
                      tribute2.damage = 0
                      tribute2.stamina += 5
                      tribute1.inv[1] = [nil, 0]
                    end
                    break
                  end
                end

                #decides whether tribute1 will fight, flee, or negotiate based on their stats
                #(uses a marble bag method)
                statmax1 = tribute1.strength + tribute1.agility + tribute1.intellect
                case
                when rand(statmax1) < tribute1.strength + tribute1.aggression
                  method1 = [tribute1.strength, 0]
                when rand(statmax1) > tribute1.strength + tribute1.agility
                  method1 = [tribute1.agility, 1]
                else
                  method1 = [tribute1.intellect, 2]
                end

                #same but for tribute2
                statmax2 = tribute2.strength + tribute2.agility + tribute2.intellect
                case
                when rand(statmax2) < tribute2.strength + tribute2.aggression
                  method2 = [tribute2.strength, 0]
                when rand(statmax2) > tribute2.strength + tribute2.agility
                  method2 = [tribute2.agility, 1]
                else
                  method2 = [tribute2.intellect, 2]
                end

                #determines if a tribute has an ally involved in the conflict
                allybonus1 = 0
                allybonus2 = 0
                allybonus1 = 2 if tribute1.ally != nil && tribute1.ally.loc_x == tribute1.loc_x && tribute1.ally.loc_y == tribute1.loc_y
                allybonus2 = 2 if tribute2.ally != nil && tribute2.ally.loc_x == tribute2.loc_x && tribute2.ally.loc_y == tribute2.loc_y

                #stat comparisons + rng to determine encounter outcome
                if (method1[0] + rand(3) + tribute1.divine_power + (tribute1.stamina / 10) + tribute1.inv[0][1]) - (tribute1.damage * 3) + allybonus1 > (method2[0] + rand(3) + tribute2.divine_power + (tribute2.stamina / 10) + tribute2.inv[0][1]) - (tribute1.damage * 3) + allybonus2
                  case
                  when method1[1] == 0
                    temp = 0
                    temp = 1 if tribute1.inv[0][1] !=  0
                    if rand(3) == 0 || rand(3) == temp
                      entry[queue] = "#{key1} kills #{key2} with #{tribute1.inv[0][0]}"
                      queue += 1
                      tribute1.stamina -= 1
                      tributes.delete(key2)
                      markers[key2].remove
                      dead = key2
                      tribute2.ally.ally = nil unless tribute2.ally == nil
                    else
                      entry[queue] = "#{key1} injures #{key2} with #{tribute1.inv[0][0]}"
                      queue += 1
                      tribute1.stamina -= 1
                      tribute2.damage += 1
                    end
                  when method1[1] == 1
                    entry[queue] = "#{key1} flees from #{key2}"
                    queue += 1
                    tribute1.stamina -= 2
                  when method1[1] == 2
                    entry[queue] = "#{key1} convinces #{key2} to provide assistance"
                    queue += 1
                    tribute1.stamina += 4
                    tribute2.stamina -= 2
                    if tribute1.aggression < 0 && method1[0] + rand(3) + tribute1.divine_power > 8 && tribute2.aggression < 1
                      tribute1.ally = tribute2
                      tribute2.ally = tribute1
                      entry[queue] = "#{key1} and #{key2} enter an alliance"
                      queue += 1
                    end
                  end
                else
                  case
                  when method2[1] == 0
                    temp = 0
                    temp = 1 if tribute2.inv[0][1] !=  0
                    if rand(3) == 0 || rand(3) == temp
                      entry[queue] = "#{key2} kills #{key1} with #{tribute2.inv[0][0]}"
                      queue += 1
                      tribute2.stamina -= 1
                      tributes.delete(key1)
		      markers[key1].remove
                      dead = key1
                      tribute1.ally.ally = nil unless tribute1.ally == nil
                    else
                      entry[queue] = "#{key1} injures #{key2} with #{tribute1.inv[0][0]}"
                      queue += 1
                      tribute1.stamina -= 1
                      tribute2.damage += 1
                    end
                  when method2[1] == 1
                    entry[queue] = "#{key2} flees from #{key1}"
                    queue += 1
                    tribute2.stamina -= 2
                  when method2[1] == 2
                    entry[queue] = "#{key2} convinces #{key1} to provide assistance"
                    queue += 1
                    tribute2.stamina += 4
                    tribute1.stamina -= 2
                    if tribute2.aggression == 2 && method1[0] + rand(3) + tribute2.divine_power > 8 && tribute1.aggression < 1
                      tribute1.ally = tribute2
                      tribute2.ally = tribute1
                      entry[queue] = "#{key1} and #{key2} enter an alliance"
                      queue += 1
                    end
                  end
                end
              end
            end
        end
      end
    end
    unless entry == nil
      entry.each do |item|
        entries.each do |line|
          unless line == nil
            line.y -= 20
            line.remove if line.y <= 70
            j += 1
          end
        end
        entries[j] = Text.new("#{item}", size: 18, font: 'SLC_.ttf', color: 'black', z: 99, x: 515, y: 415)
        sleep(0.5)
      end
    end
end

show
