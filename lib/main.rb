require "tty-prompt"
require "colorize"
require_relative "sub_menu.rb"
require_relative "list.rb"
require_relative "menu.rb"

list = List.new
list.load_tasks

menu = Menu.new
list.deselect_all_tasks
list.write_tasks

while true
    system('cls') || system('clear')
    list.load_tasks
    menu.populate_options(list.list_task_descriptions)
    answer = menu.construct(list)
    list.deselect_task(list.selected_task_id)
    if answer == :ADD
        puts "Enter description:"
        name = gets.strip()
        list.add_task(name)
        list.write_tasks
    elsif answer.class == Integer && list.tasks[list.id_to_index(answer)]["status"] == "incomplete"
        system('cls') || system('clear')
        list.select_task(answer)
        sub_menu = SubMenu.new
        sub_menu.populate_options(list.list_greyed, list)
        subanswer = sub_menu.construct
        system('cls') || system('clear')
        if subanswer == :DELETE
            TTY::Prompt.new.select("Delete '#{list.tasks[list.selected_task]["description"]}'?", {"Yes"=>true,"No"=>false}, help: "") ?
            list.delete_task(list.selected_task_id) :
            true
        elsif subanswer == :MOVE
            menu.move(list)
        elsif subanswer == :RENAME
            name = TTY::Prompt.new.ask(" Enter new description:\n", value: "#{list.tasks[list.selected_task]["description"]}")
            list.rename_task(name)
        elsif subanswer == :COMPLETE
            list.complete_task
        end
        list.write_tasks
    elsif answer.class == Integer && list.tasks[list.id_to_index(answer)]["status"] == "complete"
        system('cls') || system('clear')
        list.select_task(answer)
        sub_menu = SubMenu.new
        sub_menu.populate_comp_options(list.list_greyed, list)
        subanswer = sub_menu.construct
        system('cls') || system('clear')
        if subanswer == :DELETE
            TTY::Prompt.new.select("Delete '#{list.tasks[list.selected_task]["description"]}'?", {"Yes"=>true,"No"=>false}, help: "") ?
            list.delete_task(list.selected_task_id) :
            true
        elsif subanswer == :REOPEN
            list.reopen_task
        end
        list.write_tasks
    elsif answer == :QUIT
        return false
    end
end