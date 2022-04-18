require "tty-prompt"
require "colorize"
require_relative "sub_menu.rb"
require_relative "list.rb"
require_relative "menu.rb"
require_relative "process_argv.rb"
include ProcessARGV

if ARGV[0] == "init"
    ProcessARGV.initialize_ottr
    return
end

if ProcessARGV.init_status == true

    list = List.new
    list.load_tasks

    menu = Menu.new
    list.deselect_all_tasks
    list.write_tasks

    while true
        list.load_tasks
        menu.populate_options(list.list_task_descriptions)
        answer = menu.construct(list)
        list.deselect_all_tasks

        # TASK: LOAD TASK MENU (PARENT)
        if answer.class == Integer && list.tasks[list.id_to_index(answer)]["is_parent?"] == true
            list.select_task(answer)
            sub_menu = SubMenu.new
            sub_menu.populate_parent_options(list.list_greyed, list, list.list_child_descriptions)
            subanswer = sub_menu.construct(list)
            if subanswer == :DELETE
                sub_menu.delete(list)
            elsif subanswer == :MOVE
                menu.move(list)
            elsif subanswer == :RENAME
                name = TTY::Prompt.new.ask(" Enter new description:\n", value: "#{list.tasks[list.selected_task]["description"]}")
                list.rename_task(name)
            elsif subanswer == :COMPLETE
                list.complete_task
            elsif subanswer == :ADD
                name = name = TTY::Prompt.new.ask(" Enter new description:\n")
                list.add_child_task(name)

            # LOAD CHILD TASK SUB MENU (INCOMPLETE)
            elsif subanswer.class == Integer && !list.is_child_complete?
                list.select_child_task(answer,subanswer)
                sub_menu = SubMenu.new
                sub_menu.populate_child_options(list.list_all_greyed, list, list.list_child_descriptions_greyed)
                subanswer = sub_menu.construct(list)
                if subanswer == :DELETE
                    sub_menu.delete_child_task(list)
                elsif subanswer == :MOVE
                    puts "this worked"
                    sub_menu.move_child(list)
                elsif subanswer == :RENAME
                    name = TTY::Prompt.new.ask(" Enter new description:\n", value: "#{list.selected_child_name}")
                    list.rename_child_task(name)
                elsif subanswer == :COMPLETE
                    list.complete_child_task
                end
                list.write_tasks

            # LOAD CHILD TASK SUB MENU (COMPLETE)
            elsif subanswer.class == Integer && list.is_child_complete?
                list.select_child_task(answer,subanswer)
                sub_menu = SubMenu.new
                sub_menu.populate_child_comp_options(list.list_all_greyed, list, list.list_child_descriptions_greyed)
                subanswer = sub_menu.construct(list)
                if subanswer == :DELETE
                    sub_menu.delete_child_task(list)
                elsif subanswer == :REOPEN
                    list.reopen_child_task
                end
                list.write_tasks
            end
            list.write_tasks

        
        # TASK: LOAD MASTER TASK MENU (NOT PARENT)
        elsif answer.class == Integer && !list.is_complete?(answer)
            list.select_task(answer)
            sub_menu = SubMenu.new
            sub_menu.populate_options(list.list_greyed, list)
            subanswer = sub_menu.construct(list)
            if subanswer == :DELETE
                sub_menu.delete(list)
            elsif subanswer == :MOVE
                menu.move(list)
            elsif subanswer == :RENAME
                name = TTY::Prompt.new.ask(" Enter new description:\n", value: "#{list.tasks[list.selected_task]["description"]}")
                name == "" ? return : nil
                list.rename_task(name)
            elsif subanswer == :COMPLETE
                list.complete_task
            elsif subanswer == :ADD
                name = name = TTY::Prompt.new.ask(" Enter a description:\n")
                list.add_child_task(name)
            end
            list.write_tasks

        # TASK: LOAD MASTER TASK MENU (COMPLETE)
        elsif answer.class == Integer && list.is_complete?(answer)
            list.select_task(answer)
            sub_menu = SubMenu.new
            sub_menu.populate_comp_options(list.list_greyed, list)
            subanswer = sub_menu.construct(list)
            if subanswer == :DELETE
                sub_menu.delete(list)
            elsif subanswer == :REOPEN
                list.reopen_task
            end
            list.write_tasks

        # ADD TASK
        elsif answer == :ADD
            name = name = TTY::Prompt.new.ask(" Enter a description:\n")
            list.add_task(name)
            list.write_tasks

        # QUIT   
        elsif answer == :QUIT
            return
        end
    end
else
    puts "OTTR not initialized."
end