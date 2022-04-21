require 'tty-prompt'
require 'colorize'
require_relative 'list'
require_relative 'menu'

class SubMenu < Menu
  def initialize
    @DEFAULTS = [
      { '  Complete'.colorize(:cyan) => :COMPLETE },
      { '  Move'.colorize(:cyan) => :MOVE },
      { '  Rename'.colorize(:cyan) => :RENAME },
      { '  Add Task'.colorize(:cyan) => :ADD },
      { '  Delete'.colorize(:cyan) => :DELETE }
    ]
    @COMP_DEFAULTS = [
      { '  Re-open'.colorize(:cyan) => :REOPEN },
      { '  Delete'.colorize(:cyan) => :DELETE }
    ]
    @PARENT_DEFAULTS = [
      { '  Move'.colorize(:cyan) => :MOVE },
      { '  Rename'.colorize(:cyan) => :RENAME },
      { '  Add Task'.colorize(:cyan) => :ADD },
      { '  Delete'.colorize(:cyan) => :DELETE }
    ]
    @CHILD_DEFAULTS = [
      { '  Complete'.colorize(:cyan) => :COMPLETE },
      { '  Move'.colorize(:cyan) => :MOVE },
      { '  Rename'.colorize(:cyan) => :RENAME },
      { '  Delete'.colorize(:cyan) => :DELETE }
    ]
    @DISABLED_DEFAULTS = [
      { name: '  Complete'.colorize(:light_black), value: :COMPLETE, disabled: '' },
      { name: '  Move'.colorize(:light_black), value: :MOVE, disabled: '' },
      { name: '  Rename'.colorize(:light_black), value: :RENAME, disabled: '' },
      { name: '  Add Task'.colorize(:light_black), value: :ADD, disabled: '' },
      { name: '  Delete'.colorize(:light_black), value: :DELETE, disabled: '' }
    ]
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

  def populate_child_comp_options(tasks, list, children)
    @options = tasks
    @options.insert(list.selected_task + 1, children).flatten!
    @options.insert(list.selected_task + list.selected_child_task + 2, @COMP_DEFAULTS).flatten!
  end

  def populate_parent_options(tasks, list, children)
    @options = tasks
    @options.insert(list.selected_task + 1, children + @PARENT_DEFAULTS).flatten!
  end

  def populate_child_options(tasks, list, children)
    @options = tasks
    @options.insert(list.selected_task + 1, children).flatten!
    @options.insert(list.selected_task + list.selected_child_task + 2, @CHILD_DEFAULTS).flatten!
  end

  def construct(list, child)
    system('cls') || system('clear')
    Progress.new(list)
    TTY::Prompt.new.select(''.bold, symbols: { marker: '•', cross: ' ' }, active_color: :cyan) do |menu|
      menu.default child == true ? list.selected_task + list.selected_child_task + 2 : list.selected_task + list.selected_child_task + 1 
      menu.per_page 20
      menu.help ''
      menu.choices @options
    end
  end

  def delete(list)
    system('cls') || system('clear')
    if TTY::Prompt.new.select(
      "Delete '#{list.tasks[list.selected_task]['description']}'?",
      { 'Yes' => true, 'No' => false },
      help: '',
      symbols: { marker: '•', cross: ' ' },
      active_color: :cyan
    )
      list.delete_task(list.selected_task_id)
    else
      true
    end
  end

  def delete_child_task(list)
    system('cls') || system('clear')
    if TTY::Prompt.new.select(
      "Delete '#{list.selected_child_name}'?",
      { 'Yes' => true, 'No' => false },
      help: '',
      symbols: { marker: '•', cross: ' ' },
      active_color: :cyan
    )
      list.delete_child_task(list.selected_child_task_id)
      list.check_for_complete_parent == true ? list.complete_task : nil
    else
      true
    end
  end

  def move_child(list)
    system('cls') || system('clear')
    child_options = (list.list_child_mover << @DISABLED_DEFAULTS).flatten
    move_options = list.list_all_greyed
    move_options.insert(list.selected_task + 1, child_options).flatten!
    move_from = list.selected_child_task
    move_to = TTY::Prompt.new.select('OTTR LIST'.bold, active_color: :cyan,
                                                       symbols: { marker: '•', cross: ' ' }) do |menu|
      menu.per_page 20
      menu.help 'Select a new position for task (↑/↓)'
      menu.default list.selected_task + move_from + 2
      menu.choices move_options
    end
    list.move_child_task(move_from, move_to)
  end
end
