require "tty-prompt"
require "colorize"
require_relative "list.rb"

prompt = TTY::Prompt.new
list = List.new
list.load_tasks
# list.add_task("Clean room")
# list.delete_task()

while true
    list.load_tasks
    system('cls') || system('clear')

    move_from = prompt.select("", list.list_task_descriptions)
    list.select_task(move_from)

    system('cls') || system('clear')
    
    move_to = prompt.select("") do |menu| 
        menu.default (list.id_to_index(move_from) + 1)
        list.list_task_descriptions.each {|task| menu.choice task}
    end
    list.deselect_task(move_from)
    list.move_task(move_from, move_to)
    list.write_tasks    
end