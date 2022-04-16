require "tty-prompt"
require "colorize"
require_relative "list.rb"
require_relative "menu.rb"


class SubMenu < Menu

    def initialize
        @DEFAULTS = [
            {"  Complete"=>:COMPLETE},
            {"  Move"=>:MOVE},
            {"  Rename"=>:RENAME},
            {"  Add Task".colorize(:cyan)=>:ADD},
            {"  Delete".colorize(:cyan)=>:DELETE}]
        @COMP_DEFAULTS = [
            {"  Re-open"=>:REOPEN},
            {"  Delete".colorize(:cyan)=>:DELETE}]
        @loads = 0
    end

    def populate_options(tasks, list)
        @options = tasks
        @options.insert(list.selected_task + 1, @DEFAULTS).flatten!
    end

    def construct
        TTY::Prompt.new.select("Ottr Project".bold, symbols: {cross: " "}, active_color: :cyan) do |menu|
            menu.per_page 20
            menu.help ""
            menu.choices @options
        end
    end

    def populate_comp_options(tasks, list)
        @options = tasks
        @options.insert(list.selected_task + 1, @COMP_DEFAULTS).flatten!
    end

end
