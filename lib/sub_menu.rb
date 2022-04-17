require "tty-prompt"
require "colorize"
require_relative "list.rb"
require_relative "menu.rb"


class SubMenu < Menu

    def initialize
        @DEFAULTS = [
            {"  Complete".colorize(:cyan)=>:COMPLETE},
            {"  Move".colorize(:cyan)=>:MOVE},
            {"  Rename".colorize(:cyan)=>:RENAME},
            {"  Add Task".colorize(:cyan)=>:ADD},
            {"  Delete".colorize(:cyan)=>:DELETE}]
        @COMP_DEFAULTS = [
            {"  Re-open".colorize(:cyan)=>:REOPEN},
            {"  Delete".colorize(:cyan)=>:DELETE}]
        @PARENT_DEFAULTS = [
            {"  Complete".colorize(:cyan)=>:COMPLETE},
            {"  Move".colorize(:cyan)=>:MOVE},
            {"  Rename".colorize(:cyan)=>:RENAME},
            {"  Add Task".colorize(:cyan)=>:ADD},
            {"  Delete".colorize(:cyan)=>:DELETE}]
        @options = []
        @loads = 0
    end

    def populate_options(tasks, list)
        @options = tasks
        @options.insert(list.selected_task + 1, @DEFAULTS).flatten!
    end

    def populate_comp_options(tasks, list)
        @options = tasks
        @options.insert(list.selected_task + 1, @COMP_DEFAULTS).flatten!
    end

    def populate_parent_options(tasks, list, children)
        @options = tasks
        @options.insert(list.selected_task + 1, children + @PARENT_DEFAULTS).flatten!
    end

    def construct
        TTY::Prompt.new.select("OTTR LIST".bold, symbols: {marker: "•", cross: " "}, active_color: :cyan) do |menu|
            menu.per_page 20
            menu.help ""
            menu.choices @options
        end
    end

    def delete(list)
        TTY::Prompt.new.select(
            "Delete '#{list.tasks[list.selected_task]["description"]}'?", 
            {"Yes"=>true,"No"=>false}, 
            help: "", 
            symbols: {marker: "•", cross: " "}, 
            active_color: :cyan) ?
        list.delete_task(list.selected_task_id) :
        true
    end

end
