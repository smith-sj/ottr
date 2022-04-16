require "tty-prompt"
require "colorize"
require_relative "list.rb"

class Menu

    attr_reader :options

    def initialize
        @options = []
        @DEFAULTS = [{"Add task".colorize(:cyan)=>:ADD},{"Quit".colorize(:cyan)=>:QUIT}]
        #how many times has this menu been loaded
        @loads = 0
    end

    def populate_options(tasks)
        @options = (tasks << @DEFAULTS).flatten
    end

    def construct(list)
        @loads += 1
        TTY::Prompt.new.select("OTTR LIST".bold, active_color: :cyan) do |menu|
            menu.default list.selected_task + 1
            menu.per_page 20
            menu.help @loads > 1 ? "" : "\n  (Use ↑/↓ to navigate,\n  press Enter to select.\n  Scroll for more options)"
            menu.choices @options
        end
    end

    def move(list)
        move_from = list.selected_task 
        move_to = TTY::Prompt.new.select("Move".bold, active_color: :cyan) do |menu| 
            menu.default (move_from + 1)
            list.list_task_mover.each {|task| menu.choice task}
        end
        list.move_task(move_from, move_to)
    end

end