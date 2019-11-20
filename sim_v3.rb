=begin
DEVLOG:
- set up divine power stat as universal modifier
- set up random encounter system(unfinished)
- tuned RNG
- made stamina affect encounters
- set up lasting alliances
- added abbreviated logging system
- added cornucopia and inventory system
- added simple injury system
=end
class Survivor
  def initialize(strength, agility, intellect, divine_power, cooperation)
    #static attributes
    @strength = strength
    @agility = agility
    @intellect = intellect
    @divine_power = divine_power
    @cooperation = cooperation
    #variable attributes
    @loc_x = 3
    @loc_y = 3
    @stamina = 25
    @encountered = nil
    @ally = nil
    @inv = [["their bare hands", 0, "attacks"], [nil, nil]]
    @damage = 0

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
  attr_accessor :strength, :agility, :intellect, :divine_power, :cooperation
  #variable attributes
  attr_accessor :loc_x, :loc_y, :encountered, :stamina, :ally, :inv, :damage
end

tributes = {"paul" => Survivor.new(6,6,5,0,0), "jonas" => Survivor.new(3,5,6,0,1), "maddie" => Survivor.new(7, 4, 8, 0, 2),
"nash" => Survivor.new(3, 9, 5, 0, 2), "noah" => Survivor.new(6, 8, 2, 0, 2), "sam" => Survivor.new(4, 6, 5, 0, 2), "stam" => Survivor.new(8, 3, 5, 0, 2),
"jack" => Survivor.new(3, 3, 10, 0, 1), "aidan" => Survivor.new(9, 2, 7, 0, 0), "trevor" => Survivor.new(9, 3, 5, 0, 1), "ethan" => Survivor.new(5, 5, 3, 0, 1),
"elijah" => Survivor.new(6,4,7,0,0)
}

File.open("simlog.txt", 'w+') do |simlog|
  tributes.each do |key, tribute|
    if rand(2) == 0
      unless (tribute.strength + tribute.agility) / 2 + rand(3) > 5
        #TODO make it so they are killed by a given person who also went for the cornucopia(possibly reuse encounter code?)
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

  100.times do
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
          #TODO allow people with greater int stat to determine whether fruit is good
          rand(2) == 0 ? tribute.stamina += 3 : tribute.stamina -= 5
        when rand(10) == 4 || rand(10) == 8
          if tribute.agility + rand(2) + tribute.divine_power > 6
            puts "#{key} slips but catches themself"
            tribute.stamina -= 1
          else
            #TODO change from death to injury
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
            tribute.inv[0] = ["a tomahawk", 3, "chops"]
          when rand(7) == 6 && tribute.inv[0][1] < 3
            puts "#{key} is sent a broadsword"
            tribute.inv[0] = ["a broadsword", 5, "decapitates"]
          end
        when rand(10) == 7
          unless tribute.intellect + rand(2) + tribute.divine_power > 7
            puts "#{key} falls into a trap and dies."
            simlog.puts "#{key.capitalize} fails to notice a trap set by the gamemakers and is killed."
            tributes.delete(key)
          end
        end
      end
      puts ""
    end
    #checks for encounters between two people
    tributes.each do |key1, tribute1|
      tributes.each do |key2, tribute2|
          if key2 != key1 && tribute2.loc_x == tribute1.loc_x && tribute2.loc_y == tribute1.loc_y
            break if tribute1.encountered == key2
            puts "#{key1} encounters #{key2}\n"
            tribute2.encountered = key1

            #alliance encounters
            if tribute1.ally == tribute2
              if tributes.length == 2 || rand(10) == 0
                puts "#{key1} and #{key2} break their alliance"
                simlog.puts "#{key1.capitalize} and #{key2.capitalize} end their alliance."
              else
                puts "#{key1} encounters their ally #{key2}. they exchange resources."
                tribute1.stamina += 5
                tribute2.stamina += 5
                break
              end
            end

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
            if (method1[0] + rand(3) + tribute1.divine_power + (tribute1.stamina / 10) + tribute1.inv[0][1]) - (tribute1.damage * 3) > (method2[0] + rand(3) + tribute2.divine_power + (tribute2.stamina / 10) + tribute2.inv[0][1]) - (tribute1.damage * 3)
              case
              when method1[1] == 0
                if rand(3) == 0 || rand(3) == 1
                  puts "#{key1} attacks and kills #{key2} with #{tribute1.inv[0][0]}"
                  simlog.puts "#{key1.capitalize} #{tribute1.inv[0][2]} #{key2.capitalize} with #{tribute1.inv[0][0]}, killing them."
                  tribute1.stamina -= 1
                  tributes.delete(key2)
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
                if tribute1.cooperation == 2 && method1[0] + rand(3) + tribute1.divine_power > 6 && tribute2.cooperation > 0
                  tribute1.ally = tribute2
                  tribute2.ally = tribute1
                  puts "#{key1} and #{key2} enter an alliance"
                  simlog.puts "#{key1.capitalize} and #{key2.capitalize} enter a temporary alliance."
                end
              end
            else
              case
              when method2[1] == 0
                if rand(3) == 0 || rand(3) == 1
                  puts "#{key2} attacks and kills #{key1} with #{tribute2.inv[0][0]}"
                  simlog.puts "#{key2.capitalize} #{tribute2.inv[0][2]} #{key1.capitalize} with #{tribute2.inv[0][0]}, killing them."
                  tribute2.stamina -= 1
                  tributes.delete(key1)
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
                if tribute2.cooperation == 2 && method1[0] + rand(3) + tribute2.divine_power > 6 && tribute1.cooperation > 0
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
