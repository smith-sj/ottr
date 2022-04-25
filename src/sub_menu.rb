require 'tty-prompt'
require 'colorize'
require_relative 'list'
require_relative 'menu'
require_relative 'colors'

class SubMenu < Menu
  def initialize(list)
    @list = list
    @DEFAULTS = [
      { '  Complete'.colorize(Colors.MENU) => :COMPLETE },
      { '  Move'.colorize(Colors.MENU) => :MOVE },
      { '  Rename'.colorize(Colors.MENU) => :RENAME },
      { '  Add Task'.colorize(Colors.MENU) => :ADD },
      { '  Delete'.colorize(Colors.MENU) => :DELETE }
    ]
    @COMP_DEFAULTS = [
      { '  Re-open'.colorize(Colors.MENU) => :REOPEN },
      { '  Delete'.colorize(Colors.MENU) => :DELETE }
    ]
    @PARENT_DEFAULTS = [
      { '  Move'.colorize(Colors.MENU) => :MOVE },
      { '  Rename'.colorize(Colors.MENU) => :RENAME },
      { '  Add Task'.colorize(Colors.MENU) => :ADD },
      { '  Delete'.colorize(Colors.MENU) => :DELETE }
    ]
    @CHILD_DEFAULTS = [
      { '  Complete'.colorize(Colors.MENU) => :COMPLETE },
      { '  Move'.colorize(Colors.MENU) => :MOVE },
      { '  Rename'.colorize(Colors.MENU) => :RENAME },
      { '  Delete'.colorize(Colors.MENU) => :DELETE }
    ]
    @DISABLED_DEFAULTS = [
      { name: '  Complete'.colorize(Colors.DISABLED), value: :COMPLETE, disabled: '' },
      { name: '  Move'.colorize(Colors.DISABLED), value: :MOVE, disabled: '' },
      { name: '  Rename'.colorize(Colors.DISABLED), value: :RENAME, disabled: '' },
      { name: '  Add Task'.colorize(Colors.DISABLED), value: :ADD, disabled: '' },
      { name: '  Delete'.colorize(Colors.DISABLED), value: :DELETE, disabled: '' }
    ]
  end

  # METHODS FOR POPULATING MENUS

  # populates a menu for regular tasks
  def populate_options
    @options = @list.list_greyed
    @options.insert(@list.selected_task + 1, @DEFAULTS).flatten!
  end

  # populates a menu for regular tasks that are completed
  def populate_comp_options
    @options = @list.list_greyed
    @options.insert(@list.selected_task + 1, @COMP_DEFAULTS).flatten!
  end

  # populates a menu for parent tasks
  def populate_parent_options
    @options = @list.list_greyed
    @options.insert(@list.selected_task + 1, @list.list_child_descriptions + @PARENT_DEFAULTS).flatten!
  end

  # populates a menu for child tasks
  def populate_child_options
    @options = @list.list_all_greyed
    @options.insert(@list.selected_task + 1, @list.list_child_descriptions_greyed).flatten!
    @options.insert(@list.selected_task + @list.selected_child_task + 2, @CHILD_DEFAULTS).flatten!
  end

  # populates a menu for child tasks that are completed
  def populate_child_comp_options
    @options = @list.list_all_greyed
    @options.insert(@list.selected_task + 1, @list.list_child_descriptions_greyed).flatten!
    @options.insert(@list.selected_task + @list.selected_child_task + 2, @COMP_DEFAULTS).flatten!
  end

  # CONSTRUCTS A MENU CONTAINING THE POPULATED OPTIONS

  def construct(has_child)
    system('cls') || system('clear')
    Progress.new(@list)
    TTY::Prompt.new.select('OTTR LIST'.bold, symbols: { marker: '•', cross: ' ' },
                                             active_color: Colors.PRIMARY) do |menu|
      menu.default has_child ? @list.selected_task + @list.selected_child_task + 2 : @list.selected_task + @list.selected_child_task + 1
      menu.per_page 20
      menu.help ''
      menu.choices @options
    end
  end

  # CONSTRUCTS A MENU FOR DELETING TASKS

  def delete
    system('cls') || system('clear')
    if TTY::Prompt.new.select(
      "Delete '#{@list.tasks[@list.selected_task]['description']}'?",
      { 'Yes' => true, 'No' => false },
      help: '',
      symbols: { marker: '•', cross: ' ' },
      active_color: Colors.PRIMARY
    )
      @list.delete_task
    end
  end

  # CONSTRUCTS A MENU FOR WIPING ALL TASKS

  def wipe
    system('cls') || system('clear')
    if TTY::Prompt.new.select(
      'This will completely wipe your list. Are your sure?',
      { 'Yes' => true, 'No' => false },
      help: '',
      symbols: { marker: '•', cross: ' ' },
      active_color: Colors.PRIMARY
    ) &&
       TTY::Prompt.new.select(
         'There are no recovery methods... are you definitely sure?',
         { 'Yes' => true, 'No' => false },
         help: '',
         symbols: { marker: '•', cross: ' ' },
         active_color: Colors.PRIMARY
       )
      @list.wipe_tasks
    end
  end

  # CONSTRUCTS A MENU FOR DELETING CHILD TASKS

  def delete_child_task
    system('cls') || system('clear')
    if TTY::Prompt.new.select(
      "Delete '#{@list.selected_child_name}'?",
      { 'Yes' => true, 'No' => false },
      help: '',
      symbols: { marker: '•', cross: ' ' },
      active_color: Colors.PRIMARY
    )
      @list.delete_child_task
      # if remaining child tasks are complete then parent is complete
      @list.complete_task if @list.check_for_complete_parent
    end
  end

  # CONSTRUCTS A MENU FOR MOVING CHILD TASK

  def move_child
    system('cls') || system('clear')
    Progress.new(@list)
    child_options = (@list.list_child_mover << @DISABLED_DEFAULTS).flatten
    move_options = @list.list_all_greyed
    move_options.insert(@list.selected_task + 1, child_options).flatten!
    move_from = @list.selected_child_task
    move_to = TTY::Prompt.new.select('OTTR LIST'.bold, active_color: Colors.PRIMARY,
                                                       symbols: { marker: '•', cross: ' ' }) do |menu|
      menu.per_page 20
      menu.help 'Select a new position for task (↑/↓)'
      menu.default @list.selected_task + move_from + 2
      menu.choices move_options
    end
    @list.move_child_task(move_from, move_to)
  end

  # CONSTRUCTS A MINIMAL MENU FOR MOVING CHILD TASK

  def mini_move_child
    move_from = @list.selected_child_task
    move_to = TTY::Prompt.new.select('', active_color: Colors.PRIMARY,
                                         symbols: { marker: '•', cross: ' ' }) do |menu|
      menu.per_page 20
      menu.help 'Select a new position for task (↑/↓)'
      menu.default move_from + 1
      menu.choices @list.list_child_mover
    end
    @list.move_child_task(move_from, move_to)
    system('cls') || system('clear')
  end

  def name_task
    TTY::Prompt.new.ask(" Enter new description:\n")
  end

  def rename_task
    TTY::Prompt.new.ask(" Enter new description:\n", value: @list.tasks[@list.selected_task]['description'])
  end

  def rename_child
    TTY::Prompt.new.ask(" Enter new description:\n", value: @list.selected_child_name)
  end
end
