require 'tty-prompt'
require 'colorize'
require_relative 'sub_menu'
require_relative 'list'
require_relative 'menu'
require_relative 'process_argv'
require_relative 'colors'

if ARGV[0] == 'init'
  ProcessARGV.initialize_ottr
  return
end

if ProcessARGV.init_status == true
  
  list = List.new
  list.load_tasks

  # Create a menu and sub_menu object
  # to be populated later
  menu = Menu.new(list)
  sub_menu = SubMenu.new(list)

  # Deselect and save incase previous session was aborted
  list.deselect_all_tasks
  list.write_tasks

  # STARTS THE MAIN MENU LOOP
  while true
    # Save changes from previous loop
    list.write_tasks
    # Re-load saved list and show main menu
    list.load_tasks
    menu.populate_options
    answer = menu.construct
    # Previous selection cleared after menu load (keeps cursor in same position)
    list.deselect_all_tasks
    list.select_task(answer) if answer.instance_of?(Integer)

    # MAIN MENU: User selected ADD
    if answer == :ADD
      name = sub_menu.name_task
      list.add_task(name) if name != nil
      list.write_tasks

    # MAIN MENU: User selected QUIT
    elsif answer == :QUIT
      system('cls') || system('clear')
      return

    # MAIN MENU: User selected a task that is a PARENT and is COMPLETE
    elsif list.tasks[list.id_to_index(answer)]['is_parent?'] && list.tasks[list.id_to_index(answer)]['is_complete?']
        sub_menu.populate_parent_options
        subanswer = sub_menu.construct(false)
        if subanswer == :BACK
          nil
        elsif subanswer == :DELETE
          sub_menu.delete
        elsif subanswer == :MOVE
          menu.move
        elsif subanswer == :RENAME
          name = sub_menu.rename_task
          list.rename_task(name) if name != nil
        elsif subanswer == :ADD
          name = sub_menu.name_task
          list.add_child_task(name) if name != nil

        # CHILD MENU: User selected CHILD task that is COMPLETE
        else
          list.select_child_task(answer, subanswer)
          sub_menu.populate_child_comp_options
          childanswer = sub_menu.construct(true)
          if childanswer == :DELETE
            sub_menu.delete_child_task
          elsif childanswer == :REOPEN
            list.reopen_child_task
            list.reopen_task
          end
        end

    # MAIN MENU: User selected a task that is a PARENT and is INCOMPLETE
    elsif list.tasks[list.id_to_index(answer)]['is_parent?']
        sub_menu.populate_parent_options
        subanswer = sub_menu.construct(false)
        list.select_child_task(answer, subanswer) if subanswer.instance_of?(Integer)
        if subanswer == :BACK
          nil
        elsif subanswer == :DELETE
          sub_menu.delete(list)
        elsif subanswer == :MOVE
          menu.move
        elsif subanswer == :RENAME
          name = sub_menu.rename_task
          list.rename_task(name) if name != nil
        elsif subanswer == :ADD
          name = sub_menu.name_task
          list.add_child_task(name) if name != nil

        # CHILD MENU: User selected a CHILD task that is INCOMPLETE
        elsif !list.is_child_complete?
          sub_menu.populate_child_options
          subanswer = sub_menu.construct(true)
          if subanswer == :DELETE
            sub_menu.delete_child_task
          elsif subanswer == :MOVE
            sub_menu.move_child
          elsif subanswer == :RENAME
            name = sub_menu.rename_child
            list.rename_child_task(name) if name != nil
          elsif subanswer == :COMPLETE
            list.complete_child_task
            list.complete_task if list.check_for_complete_parent
          end

        # CHILD MENU: User selected a CHILD task that is COMPLETE
        elsif list.is_child_complete?
          sub_menu.populate_child_comp_options
          subanswer = sub_menu.construct(true)
          if subanswer == :DELETE
            sub_menu.delete_child_task
          elsif subanswer == :REOPEN
            list.reopen_child_task
          end
        end

    # MAIN MENU: User selected a task this is NOT A PARENT and INCOMPLETE
    elsif !list.is_complete?(answer)
      sub_menu.populate_options
      subanswer = sub_menu.construct(false)
      if subanswer == :DELETE
        sub_menu.delete
      elsif subanswer == :MOVE
        menu.move
      elsif subanswer == :RENAME
        name = sub_menu.rename_task
        list.rename_task(name) if name != nil
      elsif subanswer == :COMPLETE
        list.complete_task
      elsif subanswer == :ADD
        name = sub_menu.name_task
        list.add_child_task(name) if name != nil
      end


    # MAIN MENU: User selected a task this is NOT A PARENT and COMPLETE
    elsif list.is_complete?(answer)
      sub_menu.populate_comp_options
      subanswer = sub_menu.construct(false)
      if subanswer == :DELETE
        sub_menu.delete
      elsif subanswer == :REOPEN
        list.reopen_task
      end

    end
  end
else
  puts 'OTTR not initialized.'
end
