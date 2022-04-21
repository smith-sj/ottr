require 'tty-prompt'
require 'colorize'
require 'tty-box'
require_relative 'list'
require_relative 'progress'

class Menu
  
  attr_reader :options

  def initialize
    @options = []
    @DEFAULTS = [
      { name: 'Add task'.colorize(:cyan), value: :ADD },
      { name: 'Quit'.colorize(:cyan), value: :QUIT }
    ]
    @DISABLED_DEFAULTS = [
      { name: 'Add task'.colorize(:light_black), value: :ADD, disabled: '' },
      { name: 'Quit'.colorize(:light_black), value: :QUIT, disabled: '' }
    ]
    @loads = 0
  end

  def populate_options(tasks)
    @options = (tasks << @DEFAULTS).flatten
  end

  def construct(list)
    @loads += 1
    system('cls') || system('clear')
    Progress.new(list)
    TTY::Prompt.new.select("".bold, active_color: :cyan, symbols: { marker: '•' }) do |menu|
      menu.default list.selected_task + 1
      menu.per_page 20
      menu.help @loads > 1 ? '' : "(Use ↑/↓ to navigate,\n  press Enter to select.\n  Scroll for more options)"
      menu.choices @options
    end
  end

  def move(list)
    system('cls') || system('clear')
    Progress.new(list).strip()
    move_options = (list.list_task_mover << @DISABLED_DEFAULTS).flatten
    move_from = list.selected_task
    move_to = TTY::Prompt.new.select('OTTR LIST'.bold, active_color: :cyan,
                                                       symbols: { marker: '•', cross: ' ' }) do |menu|
      menu.per_page 20
      menu.help 'Select a new position for task (↑/↓)'
      menu.default(move_from + 1)
      menu.choices move_options
    end
    list.move_task(move_from, move_to)
  end
end
