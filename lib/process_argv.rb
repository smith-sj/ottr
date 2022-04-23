require_relative 'list'
require_relative 'sub_menu'
require 'colorize'

module ProcessARGV
  @@init_status = File.exist?('./.ottr.json')
  HELP_ERROR = "ottr does not recognize this command; try 'ottr help' for list of commands"

  def argv_parser(argv)
    start = false
    list = List.new
    list.load_tasks
    sub_menu = SubMenu.new(list)
    case argv.length
    when 0
      start = true
    when 1
      if argv[0] == 'init'
        initialize_ottr()
        start = false
      elsif argv[0] == 'log'
        list.tasks.each_with_index do |t, i|
          if t["is_complete?"] 
            puts "#{i + 1}. #{t['description']}".colorize(:light_black)
          else
            puts "#{i + 1}. #{t['description']}"
          end
          t['child_tasks'].each_with_index do |c, ii|
            if c["is_complete?"] 
              puts "    #{i + 1}.#{ii + 1}. #{c['description']}".colorize(:light_black)
            else
              puts "    #{i + 1}.#{ii + 1}. #{c['description']}"
            end
          end
        end
      elsif argv[0] == "wipe"
        sub_menu.wipe
        list.write_tasks
        puts "list wiped"
      else
        puts HELP_ERROR
      end
    when 2       
      if argv[0] == 'add'
        name = argv[1]
        list.add_task(name) if name != nil
        list.write_tasks
        start = false
      elsif argv[0] == 'comp'
        task = argv[1].to_i - 1
        list.select_task(list.tasks[task]['id'])
        if !list.tasks[task]["is_parent?"]
          list.complete_task 
        else
          puts "complete child tasks to complete parent task"
        end
        list.write_tasks
        start = false
      else
        puts HELP_ERROR
      end
    when 3 
      if argv[0] == 'add' && argv[1].to_i > 0
        task = argv[1].to_i - 1
        list.select_task(list.tasks[task]['id'])
        name = argv[2]
        list.add_child_task(name) if name != nil
        list.write_tasks
        start = false
      elsif argv[0] == 'comp'
        task = argv[1].to_i - 1
        child = argv[2].to_i - 1
        list.select_task(list.tasks[task]['id'])
        list.select_child_task(list.tasks[task]['id'], list.tasks[task]['child_tasks'][child]['id'])
        list.complete_child_task
        list.complete_task if list.check_for_complete_parent
        list.write_tasks
      else
        puts HELP_ERROR
      end
    end
    list.deselect_all_tasks
    list.write_tasks
    start
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

end
