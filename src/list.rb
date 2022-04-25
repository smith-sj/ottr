require 'colorize'
require_relative 'json_handler'
require_relative 'colors'
include JSONHandler

class List
  attr_reader :tasks

  def initialize
    @tasks = []
  end

  def load_tasks
    @tasks = json_array('.ottr.json')
  end

  def write_tasks
    write_json('.ottr.json', @tasks)
  end

  # returns an array of hashes containing task description and ID
  def list_task_descriptions
    @tasks.each_with_index.map do |task, _index|
      # if task is complete it will be returned as disabled color
      if task['is_complete?']
        # if task is a parent it will be returned with an arrow
        if task['is_parent?']
          { name: "#{task['description']} ▸".colorize(Colors.DISABLED), value: task['id'] }
        else
          { name: task['description'].colorize(Colors.DISABLED), value: task['id'] }
        end
      elsif task['is_parent?']
        { name: "#{task['description']} ▸", value: task['id'] }
      else
        { name: task['description'], value: task['id'] }
      end
    end
  end

  # returns a list of child task descr.
  def list_child_descriptions
    @tasks[selected_task]['child_tasks'].map do |task|
      # if child task is complete it will be returned with disabled color
      if task['is_complete?']
        { name: task['description'].colorize(Colors.DISABLED), value: task['id'] }
      else
        { task['description'] => task['id'] }
      end
    end
  end

  # returns child list where only selected is not greyed / disabled
  def list_child_descriptions_greyed
    @tasks[selected_task]['child_tasks'].map do |task|
      if task['is_selected_child?']
        { (task['description']).to_s => task['id'] }
      else
        { name: (task['description']).to_s.colorize(Colors.DISABLED), value: task['id'], disabled: '' }
      end
    end
  end

  # returns list specifically for moving tasks
  def list_task_mover
    @tasks.each_with_index.map do |task, index|
      if task['is_selected?']
        { task['description'].colorize(Colors.PRIMARY).blink => index }
      else
        { task['description'] => index }
      end
    end
  end

  # returns list for moving child task
  def list_child_mover
    @tasks[selected_task]['child_tasks'].each_with_index.map do |task, index|
      if task['is_selected_child?']
        { task['description'].colorize(Colors.PRIMARY).blink => index }
      else
        { task['description'] => index }
      end
    end
  end

  # returns list where parents contain arrows and completed / irrelevant tasks are greyed
  def list_greyed
    @tasks.each_with_index.map do |task, _index|
      if is_selected?(task['id'])
        if task['is_parent?']
          if task['is_complete?']
            { name: "#{task['description']} ▾".colorize(Colors.DISABLED), value: :BACK }
          else
            { name: "#{task['description']} ▾", value: :BACK }
          end
        else
          {
            name: (task['description']).to_s, value: :BACK
          }
        end
      else
        { name: task['description'].colorize(Colors.DISABLED), value: task['id'], disabled: '' }
      end
    end
  end

  # returns an entirely greyed and disblaed list
  def list_all_greyed
    @tasks.each_with_index.map do |task, _index|
      { name: task['description'].colorize(Colors.DISABLED), value: task['id'], disabled: '' }
    end
  end

  # returns all task and child-task ids
  def task_ids
    all_task_ids = @tasks.map { |task| task['id'] }
    @tasks.each do |task|
      task['child_tasks'].each do |child|
        all_task_ids.push(child['id'])
      end
    end
    all_task_ids
  end

  # returns a unique id
  def unique_id
    if @tasks.length > 0
      task_ids.max + 1
    else
      1
    end
  end

  def rename_task(name)
    @tasks[selected_task]['description'] = name
  end

  def rename_child_task(name)
    @tasks[selected_task]['child_tasks'][selected_child_task]['description'] = name
  end

  def move_task(from, to)
    @tasks = @tasks.insert(to, @tasks.delete_at(from))
  end

  def move_child_task(from, to)
    @tasks[selected_task]['child_tasks'] =
      @tasks[selected_task]['child_tasks'].insert(to, @tasks[selected_task]['child_tasks'].delete_at(from))
  end

  def add_task(description)
    @tasks.push({
                  'id' => unique_id,
                  'description' => description,
                  'is_complete?' => false,
                  'is_parent?' => false,
                  'is_selected?' => false,
                  'child_tasks' => []
                })
  end

  def add_child_task(description)
    @tasks[selected_task]['child_tasks'].push({
                                                'id' => unique_id,
                                                'description' => description,
                                                'is_complete?' => false,
                                                'is_selected_child?' => false
                                              })
    @tasks[selected_task]['is_parent?'] = true
    @tasks[selected_task]['is_complete?'] = false
  end

  def delete_task
    @tasks.delete_at(selected_task)
  end

  def delete_child_task
    @tasks[selected_task]['child_tasks'].delete_at(selected_child_task)
    @tasks[selected_task]['is_parent?'] = false if @tasks[selected_task]['child_tasks'].length < 1
  end

  def wipe_tasks
    @tasks = []
  end

  # takes a task's id and returns its index in list
  def id_to_index(id)
    index = 0
    tasks.each_with_index { |t, i| index = i if t['id'] == id }
    index
  end

  # takes a child-task's id and returns its index in list
  def child_id_to_index(pid, cid)
    index = 0
    tasks[id_to_index(pid)]['child_tasks'].each_with_index { |t, i| index = i if t['id'] == cid }
    index
  end

  # takes id and checks whether slected
  def is_selected?(id)
    @tasks[id_to_index(id)]['is_selected?']
  end

  def is_selected_child?(id)
    @tasks[selected_task]['child_tasks'][child_id_to_index(selected_task_id, id)]['is_selected_child?']
  end

  # returns index of task that is currently selected
  def selected_task
    i = 0
    @tasks.each_with_index do |task, index|
      i = index if is_selected?(task['id'])
    end
    i
  end

  # returns id of task that is currently selected
  def selected_task_id
    i = 0
    @tasks.each do |task|
      i = task['id'] if is_selected?(task['id'])
    end
    i
  end

  # returns name of task that is currently selected
  def selected_task_name
    @tasks[selected_task]['description']
  end

  def selected_child_name
    @tasks[selected_task]['child_tasks'][selected_child_task]['description']
  end

  def selected_child_task
    i = 0
    @tasks[selected_task]['child_tasks'].each_with_index do |task, index|
      i = index if task['is_selected_child?']
    end
    i
  end

  def selected_child_task_id
    i = 0
    @tasks[selected_task]['child_tasks'].each do |task|
      i = task['id'] if is_selected_child?(task['id'])
    end
    i
  end

  # selects a task
  def select_task(id)
    @tasks.each { |t| t['is_selected?'] = true if t['id'] == id }
  end

  # selects a child task
  def select_child_task(pid, cid)
    @tasks[id_to_index(pid)]['child_tasks'].each { |t| t['is_selected_child?'] = true if t['id'] == cid }
  end

  def deselect_task(id)
    @tasks.each { |t| t['is_selected?'] = false if t['id'] == id }
  end

  def deselect_child_task
    @tasks[selected_task]['child_tasks'].each { |t| t['is_selected?'] = false if t['is_selected?'] }
  end

  def deselect_all_tasks
    @tasks.each do |t|
      t['is_selected?'] = false
      t['child_tasks'].each do |ct|
        ct['is_selected_child?'] = false
      end
    end
  end

  def complete_task
    @tasks[selected_task]['is_complete?'] = true
  end

  def complete_child_task
    @tasks[selected_task]['child_tasks'][selected_child_task]['is_complete?'] = true
  end

  def reopen_child_task
    @tasks[selected_task]['child_tasks'][selected_child_task]['is_complete?'] = false
  end

  def reopen_task
    @tasks[selected_task]['is_complete?'] = false
  end

  # takes id and checks if complete
  def is_complete?(answer)
    @tasks[id_to_index(answer)]['is_complete?']
  end

  # checks if selected child task is complete
  def is_child_complete?
    @tasks[selected_task]['child_tasks'][selected_child_task]['is_complete?']
  end

  # for checking if parent is complete after its children have changed
  def check_for_complete_parent
    complete = true
    if @tasks[selected_task]['child_tasks'].length > 0
      @tasks[selected_task]['child_tasks'].each do |child_task|
        complete = false unless child_task['is_complete?']
      end
    else
      complete = false
    end
    complete
  end

  # counts total amount of tasks and child-tasks
  def count_tasks
    amount_of_tasks = @tasks.length
    @tasks.each do |task|
      amount_of_tasks -= 1 if task['is_parent?']
      amount_of_tasks += task['child_tasks'].length
    end
    amount_of_tasks
  end

  # counts total amount of complete tasks and child-tasks
  def count_complete_tasks
    complete_tasks = 0
    @tasks.each do |task|
      complete_tasks += 1 if !task['is_parent?'] && task['is_complete?']
      task['child_tasks'].each do |child_task|
        complete_tasks += 1 if child_task['is_complete?']
      end
    end
    complete_tasks
  end
end
