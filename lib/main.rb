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

  menu = Menu.new(list)
  list.deselect_all_tasks
  list.write_tasks

  while true

    list.load_tasks
    menu.populate_options
    answer = menu.construct
    list.deselect_all_tasks

    # TASK: LOAD TASK MENU (PARENT, COMPLETE)
    if answer.instance_of?(Integer) && list.tasks[list.id_to_index(answer)]['is_parent?'] && list.tasks[list.id_to_index(answer)]['is_complete?']
      list.select_task(answer)
      sub_menu = SubMenu.new(list)
      sub_menu.populate_parent_options
      subanswer = sub_menu.construct(false)
      list.select_child_task(answer, subanswer)
      if subanswer == :DELETE
        sub_menu.delete
      elsif subanswer == :MOVE
        menu.move
      elsif subanswer == :RENAME
        name = sub_menu.rename_task
        list.rename_task(name) if name != nil
      elsif subanswer == :ADD
        name = sub_menu.name_task
        list.add_child_task(name) if name != nil
      elsif subanswer.instance_of?(Integer)
        sub_menu = SubMenu.new(list)
        sub_menu.populate_child_comp_options
        childanswer = sub_menu.construct(true)
        if childanswer == :DELETE
          sub_menu.delete_child_task
        elsif childanswer == :REOPEN
          list.reopen_child_task
          list.reopen_task
        end
        list.write_tasks
      end
      list.write_tasks

    # TASK: LOAD TASK MENU (PARENT)
    elsif answer.instance_of?(Integer) && list.tasks[list.id_to_index(answer)]['is_parent?']
      list.select_task(answer)
      sub_menu = SubMenu.new(list)
      sub_menu.populate_parent_options
      subanswer = sub_menu.construct(false)
      list.select_child_task(answer, subanswer)
      if subanswer == :DELETE
        sub_menu.delete(list)
      elsif subanswer == :MOVE
        menu.move
      elsif subanswer == :RENAME
        name = sub_menu.rename_task
        list.rename_task(name) if name != nil
      elsif subanswer == :ADD
        name = sub_menu.name_task
        list.add_child_task(name) if name != nil

      # LOAD CHILD TASK SUB MENU (INCOMPLETE)
      elsif subanswer.instance_of?(Integer) && !list.is_child_complete?
        list.select_task(answer)
        sub_menu = SubMenu.new(list)
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
        list.write_tasks

      # LOAD CHILD TASK SUB MENU (COMPLETE)
      elsif subanswer.instance_of?(Integer) && list.is_child_complete?
        sub_menu = SubMenu.new(list)
        sub_menu.populate_child_comp_options
        subanswer = sub_menu.construct(true)
        if subanswer == :DELETE
          sub_menu.delete_child_task
        elsif subanswer == :REOPEN
          list.reopen_child_task
        end
        list.write_tasks
      end
      list.write_tasks

    # TASK: LOAD MASTER TASK MENU (NOT PARENT)
    elsif answer.instance_of?(Integer) && !list.is_complete?(answer)
      list.select_task(answer)
      sub_menu = SubMenu.new(list)
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
      list.write_tasks

    # TASK: LOAD MASTER TASK MENU (COMPLETE)
    elsif answer.instance_of?(Integer) && list.is_complete?(answer)
      list.select_task(answer)
      sub_menu = SubMenu.new(list)
      sub_menu.populate_comp_options
      subanswer = sub_menu.construct(false)
      if subanswer == :DELETE
        sub_menu.delete
      elsif subanswer == :REOPEN
        list.reopen_task
      end
      list.write_tasks

    # ADD TASK
    elsif answer == :ADD
      name = TTY::Prompt.new.ask(" Enter a description:\n")
      list.add_task(name) if name != nil
      list.write_tasks

    # QUIT
    elsif answer == :QUIT
      return
    end
  end
else
  puts 'OTTR not initialized.'
end
