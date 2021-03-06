require 'tty-prompt'
require 'colorize'
require 'tty-box'
require_relative 'list'
require_relative 'progress'
require_relative 'colors'

class Menu
  attr_reader :options

  def initialize(list)
    @list = list
    @options = []
    @DEFAULTS = [
      { name: '  Add task'.colorize(Colors.MENU), value: :ADD },
      { name: '  Quit'.colorize(Colors.MENU), value: :QUIT }
    ]
    @DISABLED_DEFAULTS = [
      { name: '  Add task'.colorize(Colors.DISABLED), value: :ADD, disabled: '' },
      { name: '  Quit'.colorize(Colors.DISABLED), value: :QUIT, disabled: '' }
    ]
    @loads = 0
  end

  # POPULATES MAIN MENU WITH TASKS AND DEFAULT OPTIONS

  def populate_options
    @options = (@list.list_task_descriptions << @DEFAULTS).flatten
  end

  # CONSTRUCTS MAIN MENU

  def construct
    @loads += 1
    system('cls') || system('clear')
    Progress.new(@list)
    TTY::Prompt.new.select('OTTR LIST'.bold, active_color: Colors.PRIMARY, symbols: { marker: '•' }) do |menu|
      menu.default @list.selected_task + 1
      menu.per_page 20
      menu.help @loads > 1 ? '' : "\n(Use ↑/↓ to navigate,\npress Enter to select.\nScroll for more options)"
      menu.choices @options
    end
  end

  # CONSTRUCTS A MENU FOR MOVING TASK

  def move
    system('cls') || system('clear')
    Progress.new(@list)
    move_options = (@list.list_task_mover << @DISABLED_DEFAULTS).flatten
    move_from = @list.selected_task
    move_to = TTY::Prompt.new.select('OTTR LIST'.bold, active_color: Colors.PRIMARY,
                                                       symbols: { marker: '•', cross: ' ' }) do |menu|
      menu.per_page 20
      menu.help 'Select a new position for task (↑/↓)'
      menu.default(move_from + 1)
      menu.choices move_options
    end
    @list.move_task(move_from, move_to)
  end

  # CONSTRUCTS A MINIMAL MENU FOR MOVING TASK ON CL

  def mini_move
    move_options = @list.list_task_mover
    move_from = @list.selected_task
    move_to = TTY::Prompt.new.select('', active_color: Colors.PRIMARY,
                                         symbols: { marker: '•', cross: ' ' }) do |menu|
      menu.per_page 20
      menu.help 'Select a new position for task (↑/↓)'
      menu.default(move_from + 1)
      menu.choices move_options
    end
    @list.move_task(move_from, move_to)
    system('cls') || system('clear')
  end
end
