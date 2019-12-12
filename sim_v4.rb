=begin
DEVLOG:
- weapons made more likely to kill than unarmed attacks
- allies now share medical supplies.
- aggression stat implemented
- made map boundaries encroach as more tributes die
- fixed bug where dead tributes would go on to interact with others
- allies now give each other bonuses in encounters
=end

#map limits
$max_x = 5
$max_y = 5

class Survivor
  def initialize(strength, agility, intellect, divine_power, aggression)
    #static attributes
    @strength = strength
    @agility = agility
    @intellect = intellect
    @divine_power = divine_power
    @aggression = aggression
    #variable attributes
    @loc_x = 3
    @loc_y = 3
    @stamina = 30
    @encountered = nil
    @ally = nil
    @inv = [["their bare hands", 0, "attacks"], [nil, nil]]
    @damage = 0
  end
  def move
    #picks randomly which axis to move on and then in which direction(and has people follow their allies)
    #also sets the size of the map
    unless @ally == nil
      if @ally.loc_x == @loc_x + 1 || @ally.loc_x == @loc_x - 1
        if @ally.loc_y == @loc_y + 1 || @ally.loc_y == @loc_y - 1
          puts "near alliance1: #{self}"
          puts @loc_x
          puts @loc_y
          puts @ally.loc_x
          puts @ally.loc_y
          case
          when @ally.loc_x - 1 == @loc_x
            puts "x+1"
            @loc_x += 1
          when @ally.loc_x + 1 == @loc_x
            puts "x-1"
            @loc_x -= 1
          when @ally.loc_x - 1 == @loc_y
            puts "y+1"
            @loc_y += 1
          when @ally.loc_x + 1 == @loc_y
            puts "y-1"
            @loc_y -= 1
          end
        end
      else
        if rand(2) == 0
       unless @loc_x == 1 || @loc_x == $max_x
         rand(2) == 0 ? @loc_x += 1 : @loc_x -= 1
       else
         @loc_x == 1 ? @loc_x +=1 : @loc_x -= 1
       end
      else
        unless @loc_y == 1 || @loc_y == $max_y
          rand(2) == 0 ? @loc_y += 1 : @loc_y -= 1
        else
          @loc_y == 1 ? @loc_y +=1 : @loc_y -= 1
        end
        end
      end
    else
       if rand(2) == 0
       unless @loc_x == 1 || @loc_x == $max_x
         rand(2) == 0 ? @loc_x += 1 : @loc_x -= 1
       else
         @loc_x == 1 ? @loc_x +=1 : @loc_x -= 1
       end
      else
        unless @loc_y == 1 || @loc_y == $max_y
          rand(2) == 0 ? @loc_y += 1 : @loc_y -= 1
        else
          @loc_y == 1 ? @loc_y +=1 : @loc_y -= 1
        end
      end
    end

  end
  #static attributes
  attr_accessor :strength, :agility, :intellect, :divine_power, :aggression
  #variable attributes
  attr_accessor :loc_x, :loc_y, :encountered, :stamina, :ally, :inv, :damage
end

#seed to use
#srand(1111)

tributes = {"paul" => Survivor.new(6,6,5,0,0), "jonas" => Survivor.new(3,5,6,0,-1), "maddie" => Survivor.new(7, 4, 8, 0, -2),
"nash" => Survivor.new(3, 9, 5, 0, -1), "noah" => Survivor.new(6, 8, 2, 0, -1), "sam" => Survivor.new(4, 6, 5, 0, -2), "stam" => Survivor.new(8, 3, 5, 0, -2),
"jack" => Survivor.new(3, 3, 10, 0, -1), "aidan" => Survivor.new(9, 2, 7, 3, 3), "trevor" => Survivor.new(9, 3, 5, 0, -1),
"elijah" => Survivor.new(6,4,7,0,0), "jamal" => Survivor.new(4, 8, 3, 0, 2), "simon" => Survivor.new(1, 1, 1, 0, 1)
}



tribnum = tributes.length
dead = nil

File.open("simlog.txt", 'w+') do |simlog|
  tributes.each do |key, tribute|
    if rand(2) == 0
      unless (tribute.strength + tribute.agility) / 2 + rand(3) > 5
        puts "#{key} goes for the cornucopia but is killed in the chaos"
        simlog.puts "#{key.capitalize} goes for the cornucopia but is killed in the chaos."
        tributes.delete(key)
      else
        case
        when rand(5) == 0 || rand(5) == 1
          puts "#{key} grabs a dagger from the cornucopia"
          tribute.inv[0] = ["a dagger", 2, "stabs"]
        when rand(5) == 3 || rand(5) == 4
          puts "#{key} grabs a war scythe from the cornucopia"
          tribute.inv[0] = ["a war scythe", 4, "reaps"]
        end
      end
    else
      puts "#{key} forgoes the cornucopia and escapes the starting area"
      tribute.stamina += 2
    end
  end

  while true do
    #changes map bounds as tributes thin out
    if tributes.length < tribnum / 2
      unless $max_x < 3
        temp = false
        tributes.each do |key, tribute|
          temp = true if tribute.loc_x == $max_x
        end
        $max_x -= 1 unless temp
      end
      unless $max_y < 3
        temp = false
        tributes.each do |key, tribute|
          temp = true if tribute.loc_y == $max_y
        end
        $max_y -= 1 unless temp
      end
    end

    #moves each tribute, lowers stamina, and logs new coordinates
    if tributes.length == 1
      puts "#{tributes.keys} is victorious"
      temp = tributes.keys
      simlog.puts "#{temp[0].capitalize} wins!"
      break
    end
    tributes.each do |key, tribute|
      tribute.encountered = nil
      tribute.move
      tribute.stamina -= 1
      if tribute.stamina < 1
        puts "#{key} collapses in exhaustion and dies slowly."
        simlog.puts "#{key.capitalize} dies of exposure."
        tributes.delete(key)
        tribute.ally.ally = nil unless tribute.ally == nil
      elsif tribute.damage > 0 && tribute.inv[1][0] == "medical supplies"
        tribute.inv[1] = [nil, 0]
        tribute.stamina += 10
        tribute.damage = 0
        puts "#{key} uses medical supplies"
        simlog.puts "#{key.capitalize} applies first aid using supplies they had found."
      end
      if tribute.damage > 1
        puts "#{key} dies"
        simlog.puts "#{key.capitalize} succumbs to their wounds."
        tributes.delete(key)
        tribute.ally.ally = nil unless tribute.ally == nil
        break
      end
      puts "x of #{key}: #{tribute.loc_x}"
      puts "y of #{key}: #{tribute.loc_y}"
      #1/3 chance of random encounter
      if rand(3) == 0
        case
        when rand(10) == 0 || rand(10) == 1
          tribute.stamina += 3
          puts "#{key} finds a source of fresh water."
        when rand(10) == 2 || rand(10) == 3
          puts "#{key} eats some wild greens."
          rand(2) == 0 ? tribute.stamina += 3 : tribute.stamina -= 5
        when rand(10) == 4 || rand(10) == 8
          if tribute.agility + rand(2) + tribute.divine_power > 6
            puts "#{key} slips but catches themself"
            tribute.stamina -= 1
          else
            puts "#{key} slips and is injured"
            simlog.puts "#{key.capitalize} missteps and is injured."
            tribute.damage += 1
          end
        when rand(10) == 5 || rand(10) == 6
          case
          when rand(7) == 0 || rand(7) == 1 && tribute.inv[0][1] < 1
            puts "#{key} is sent a shank"
            tribute.inv[0] = ["a shank", 1, "stabs"]
          when rand(7) == 2 || rand(7) == 3 && tribute.inv[1]
            puts "#{key} is sent some medical supplies"
            tribute.inv[1] = ["medical supplies", 10]
          when rand(7) == 5 && tribute.inv[0][1] < 3
            puts "#{key} is sent a tomahawk"
            tribute.inv[0] = ["a tomahawk", 3, "attacks"]
          when rand(7) == 6 && tribute.inv[0][1] < 3
            puts "#{key} is sent a broadsword"
            tribute.inv[0] = ["a broadsword", 5, "slices"]
          end
        when rand(10) == 7
          unless tribute.intellect + rand(2) + tribute.divine_power > 7
            puts "#{key} falls into a trap and dies."
            simlog.puts "#{key.capitalize} fails to notice a trap set by the gamemakers and is killed."
            tributes.delete(key)
            tribute.ally.ally = nil unless tribute.ally == nil
          end
        end
      end
      puts ""
    end

    #checks for encounters between two people
    tributes.each do |key1, tribute1|
      unless dead == key1
        tributes.each do |key2, tribute2|
            if key2 != key1 && tribute2.loc_x == tribute1.loc_x && tribute2.loc_y == tribute1.loc_y
              unless dead == key2 || dead == key1
                break if tribute1.encountered == key2
                puts "#{key1} encounters #{key2}\n"
                tribute2.encountered = key1

                #alliance encounters
                if tribute1.ally == tribute2
                  if tributes.length == 2 || rand(10) == 0
                    puts "#{key1} and #{key2} break their alliance"
                    simlog.puts "#{key1.capitalize} and #{key2.capitalize} end their alliance."
                    tribute1.ally = nil
                    tribute2.ally = nil
                  else
                    simlog.puts "ally encounter"
                    puts "#{key1} encounters their ally #{key2}. they exchange resources."
                    tribute1.stamina += 3
                    tribute2.stamina += 3
                    if tribute1.damage == 1 && tribute2.inv[1][0] == "medical supplies"
                      puts "#{key2} shares their medical supplies with #{key1}"
                      simlog.puts "#{key2.capitalize} shares their medical supplies with #{key1.capitalize}."
                      tribute1.damage = 0
                      tribute1.stamina += 5
                      tribute2.inv[1] = [nil, 0]
                    elsif tribute2.damage == 1 && tribute1.inv[1][0] == "medical supplies"
                      puts "#{key1} shares their medical supplies with #{key2}"
                      simlog.puts "#{key1.capitalize} shares their medical supplies with #{key2.capitalize}."
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
                      puts "#{key1} attacks and kills #{key2} with #{tribute1.inv[0][0]}"
                      simlog.puts "#{key1.capitalize} #{tribute1.inv[0][2]} #{key2.capitalize} with #{tribute1.inv[0][0]}, killing them."
                      tribute1.stamina -= 1
                      tributes.delete(key2)
                      dead = key2
                      tribute2.ally.ally = nil unless tribute2.ally == nil
                    else
                      puts "#{key1} attacks #{key2} with #{tribute1.inv[0][0]}, injuring but not killing #{key2}"
                      simlog.puts "#{key1.capitalize} #{tribute1.inv[0][2]} #{key2.capitalize} with #{tribute1.inv[0][0]}, injuring them."
                      tribute1.stamina -= 1
                      tribute2.damage += 1
                    end
                  when method1[1] == 1
                    puts "#{key1} flees"
                    tribute1.stamina -= 2
                  when method1[1] == 2
                    puts "#{key1} convinces #{key2} to provide assistance"
                    tribute1.stamina += 4
                    tribute2.stamina -= 2
                    if tribute1.aggression < 0 && method1[0] + rand(3) + tribute1.divine_power > 5 && tribute2.aggression < 1
                      tribute1.ally = tribute2
                      tribute2.ally = tribute1
                      puts "#{key1} and #{key2} enter an alliance"
                      simlog.puts "#{key1.capitalize} and #{key2.capitalize} enter a temporary alliance."
                    end
                  end
                else
                  case
                  when method2[1] == 0
                    temp = 0
                    temp = 1 if tribute2.inv[0][1] !=  0
                    if rand(3) == 0 || rand(3) == temp
                      puts "#{key2} attacks and kills #{key1} with #{tribute2.inv[0][0]}"
                      simlog.puts "#{key2.capitalize} #{tribute2.inv[0][2]} #{key1.capitalize} with #{tribute2.inv[0][0]}, killing them."
                      tribute2.stamina -= 1
                      tributes.delete(key1)
                      dead = key1
                      tribute1.ally.ally = nil unless tribute1.ally == nil
                    else
                      puts "#{key1} attacks #{key2} with #{tribute1.inv[0][0]}, injuring but not killing #{key2}"
                      simlog.puts "#{key1.capitalize} #{tribute1.inv[0][2]} #{key2.capitalize} with #{tribute1.inv[0][0]}, injuring them."
                      tribute1.stamina -= 1
                      tribute2.damage += 1
                    end
                  when method2[1] == 1
                    puts "#{key2} flees"
                    tribute2.stamina -= 2
                  when method2[1] == 2
                    puts "#{key2} convinces #{key1} to provide assistance"
                    tribute2.stamina += 4
                    tribute1.stamina -= 2
                    if tribute2.aggression == 2 && method1[0] + rand(3) + tribute2.divine_power > 5 && tribute1.aggression < 1
                      tribute1.ally = tribute2
                      tribute2.ally = tribute1
                      puts "#{key1} and #{key2} enter an alliance"
                      simlog.puts "#{key1.capitalize} and #{key2.capitalize} enter a temporary alliance."
                    end
                  end
                end
              end
            end
        end
      end
    end
  end
end
