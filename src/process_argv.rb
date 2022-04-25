require_relative 'list'
require_relative 'sub_menu'
require 'colorize'

module ProcessARGV
  @@init_status = File.exist?('./.ottr.json')
  HELP_ERROR = "Command not recognized. Try 'ottr help' for list of commands"
  TASK_ERROR = "Selected task does not exist, try 'ottr log' to find intended task."
  INDENT = ' ' * 4

  # prints confirmation feedback to user
  def feedback(list, action, is_child = false)
    if list.nil?
      puts action
    elsif is_child
      puts "#{list.selected_child_name}: " + action
    else
      puts "#{list.selected_task_name}: " + action
    end
  end

  def task_exist(list, task)
    (0..list.tasks.length - 1).include?(task.to_i - 1)
  end

  def child_exist(list, task, child)
    (0..list.tasks[task.to_i - 1]['child_tasks'].length - 1).include?(child.to_i - 1)
  end

  def initialize_ottr
    if @@init_status == true
      puts 'already initialized'
    else
      List.new.write_tasks
      puts 'ottr initialized'
    end
  end

  def self.init_status
    @@init_status
  end

  def argv_parser(argv)
    if argv[0] == 'init'
      initialize_ottr
      return false
    elsif !@@init_status
      puts 'ottr not initialized'
      return false
    end

    start = false
    list = List.new
    list.load_tasks
    sub_menu = SubMenu.new(list)
    list.deselect_all_tasks
    case argv.length

    when 0
      start = true

    when 1
      if argv[0] == 'log'
        list.tasks.each_with_index do |t, i|
          if t['is_complete?']
            puts "#{i + 1}. #{t['description']}".colorize(:light_black)
          else
            puts "#{i + 1}. #{t['description']}"
          end
          t['child_tasks'].each_with_index do |c, ii|
            if c['is_complete?']
              puts "#{INDENT}#{i + 1}.#{ii + 1}. #{c['description']}".colorize(:light_black)
            else
              puts "#{INDENT}#{i + 1}.#{ii + 1}. #{c['description']}"
            end
          end
        end
      elsif argv[0] == 'wipe'
        sub_menu.wipe
        list.write_tasks
        feedback(nil, 'list wiped')
      else
        puts HELP_ERROR
      end

    when 2
      if argv[0] == 'add'
        name = argv[1]
        if name.strip == ''
          puts 'Name must contain characters'
        else
          list.add_task(name)
          feedback(nil, "#{name}: added")
        end
      elsif argv[0] == 'comp'
        if !task_exist(list, argv[1])
          puts TASK_ERROR
        else
          task = argv[1].to_i - 1
          list.select_task(list.tasks[task]['id'])
          if !list.tasks[task]['is_parent?']
            list.complete_task
            feedback(list, 'completed')
          else
            puts 'complete child tasks to complete parent task'
          end
        end
      elsif argv[0] == 'del'
        if !task_exist(list, argv[1])
          puts TASK_ERROR
        else
          task = argv[1].to_i - 1
          list.select_task(list.tasks[task]['id'])
          # save name to reference after deletion
          name = list.selected_task_name
          sub_menu.delete
          feedback(nil, "#{name}: deleted")
        end
      elsif argv[0] == 'open'
        if !task_exist(list, argv[1])
          puts TASK_ERROR
        else
          task = argv[1].to_i - 1
          list.select_task(list.tasks[task]['id'])
          if !list.tasks[task]['is_parent?']
            list.reopen_task
            feedback(list, 're-opened')
          else
            puts 're-open child tasks to re-open parent task'
          end
        end
      elsif argv[0] == 'move'
        if !task_exist(list, argv[1])
          puts TASK_ERROR
        else
          task = argv[1].to_i - 1
          list.select_task(list.tasks[task]['id'])
          sub_menu.mini_move
          feedback(list, 'moved')
        end
      elsif argv[0] == 'name'
        if !task_exist(list, argv[1])
          puts TASK_ERROR
        else
          task = argv[1].to_i - 1
          list.select_task(list.tasks[task]['id'])
          name = sub_menu.rename_task
          list.rename_task(name) unless name.nil?
          feedback(list, 'renamed')
        end
      else
        puts HELP_ERROR
      end

    when 3
      if argv[0] == 'add' && argv[1].to_i > 0
        task = argv[1].to_i - 1
        list.select_task(list.tasks[task]['id'])
        name = argv[2]
        list.add_child_task(name) unless name.nil?
        feedback(nil, "#{name}: added")
      elsif argv[0] == 'comp'
        if !child_exist(list, argv[1], argv[2])
          puts TASK_ERROR
        else
          task = argv[1].to_i - 1
          child = argv[2].to_i - 1
          list.select_task(list.tasks[task]['id'])
          list.select_child_task(list.tasks[task]['id'], list.tasks[task]['child_tasks'][child]['id'])
          list.complete_child_task
          list.complete_task if list.check_for_complete_parent
          feedback(list, 'completed', true)
        end
      elsif argv[0] == 'del'
        if !child_exist(list, argv[1], argv[2])
          puts TASK_ERROR
        else
          task = argv[1].to_i - 1
          child = argv[2].to_i - 1
          list.select_task(list.tasks[task]['id'])
          list.select_child_task(list.tasks[task]['id'], list.tasks[task]['child_tasks'][child]['id'])
          # save name to reference after deletion
          name = list.selected_child_name
          sub_menu.delete_child_task
          feedback(nil, "#{name}: deleted")
        end
      elsif argv[0] == 'open'
        if !child_exist(list, argv[1], argv[2])
          puts TASK_ERROR
        else
          task = argv[1].to_i - 1
          child = argv[2].to_i - 1
          list.select_task(list.tasks[task]['id'])
          list.select_child_task(list.tasks[task]['id'], list.tasks[task]['child_tasks'][child]['id'])
          list.reopen_child_task
          list.reopen_task unless list.check_for_complete_parent
          feedback(list, 're-opened', true)
        end
      elsif argv[0] == 'move'
        if !child_exist(list, argv[1], argv[2])
          puts TASK_ERROR
        else
          task = argv[1].to_i - 1
          child = argv[2].to_i - 1
          list.select_task(list.tasks[task]['id'])
          list.select_child_task(list.tasks[task]['id'], list.tasks[task]['child_tasks'][child]['id'])
          sub_menu.mini_move_child
          feedback(list, 'moved', true)
        end
      elsif argv[0] == 'name'
        if !child_exist(list, argv[1], argv[2])
          puts TASK_ERROR
        else
          task = argv[1].to_i - 1
          child = argv[2].to_i - 1
          list.select_task(list.tasks[task]['id'])
          list.select_child_task(list.tasks[task]['id'], list.tasks[task]['child_tasks'][child]['id'])
          name = sub_menu.rename_child
          list.rename_child_task(name) unless name.nil?
          feedback(list, 'renamed', true)
        end
      else
        puts HELP_ERROR
      end

    else
      puts HELP_ERROR
    end

    list.deselect_all_tasks
    list.write_tasks
    start
  end
end
