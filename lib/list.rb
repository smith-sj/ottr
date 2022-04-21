require 'colorize'
require_relative 'json_handler'
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
  # if the task is selected it is returned green
  def list_task_descriptions
    @tasks.each_with_index.map do |task, _index|
      if task['is_complete?']
        task['is_parent?'] ?
        { name: "#{task['description']} ▸".colorize(:light_black), value: task['id'] } :
        { name: task['description'].colorize(:light_black), value: task['id'] }
      elsif task['is_parent?']
        { "#{task['description']} ▸" => task['id'] }
      else
          { task['description'] => task['id'] }
      end
    end
  end

  def list_child_descriptions
    @tasks[selected_task]['child_tasks'].map do |task|
      if task['is_complete?'] == true
        { name: (task['description']).to_s.colorize(:light_black), value: task['id'] }
      else
        { (task['description']).to_s => task['id'] }
      end
    end
  end

  def list_child_descriptions_greyed
    @tasks[selected_task]['child_tasks'].map do |task|
      if task['is_selected_child?']
        { (task['description']).to_s => task['id'] }
      else
        { name: (task['description']).to_s.colorize(:light_black), value: task['id'], disabled: '' }
      end
    end
  end

  def list_task_mover
    @tasks.each_with_index.map do |task, index|
      if task['is_selected?']
        { task['description'].colorize(:cyan).blink => index }
      else
        { task['description'] => index }
      end
    end
  end

  def list_child_mover
    @tasks[selected_task]['child_tasks'].each_with_index.map do |task, index|
      if task['is_selected_child?']
        { task['description'].colorize(:cyan).blink => index }
      else
        { task['description'] => index }
      end
    end
  end

  def list_greyed
    @tasks.each_with_index.map do |task, _index|
      if is_selected?(task['id'])
        if task['is_parent?'] == true
          task['is_complete?'] ?
          { name: "#{task['description']} ▾".colorize(:light_black), value: :BACK } :
          { name: "#{task['description']} ▾", value: :BACK }
        else
          {
            name: (task['description']).to_s, value: :BACK
          }
        end
      else
        { name: task['description'].colorize(:light_black), value: task['id'], disabled: '' }
      end
    end
  end

  def list_all_greyed
    @tasks.each_with_index.map do |task, _index|
      { name: task['description'].colorize(:light_black), value: task['id'], disabled: '' }
    end
  end

  def task_ids
    all_task_ids = @tasks.map { |task| task['id'] }
    @tasks.each do |task|
      task['child_tasks'].each do |child|
        all_task_ids.push(child['id'])
      end
    end
    all_task_ids
  end

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
  end

  def delete_task(target)
    @tasks.delete_if { |task| task['id'] == target }
  end

  def delete_child_task(_target)
    @tasks[selected_task]['child_tasks'].delete_at(selected_child_task)
    @tasks[selected_task]['child_tasks'].length < 1 ? @tasks[selected_task]['is_parent?'] = false : nil
  end

  def id_to_index(id)
    index = 0
    tasks.each_with_index { |t, i| t['id'] == id ? index = i : nil }
    index
  end

  def child_id_to_index(pid, cid)
    index = 0
    tasks[id_to_index(pid)]['child_tasks'].each_with_index { |t, i| t['id'] == cid ? index = i : nil }
    index
  end

  def is_selected?(id)
    @tasks[id_to_index(id)]['is_selected?'] == true
  end

  def is_selected_child?(id)
    @tasks[selected_task]['child_tasks'][child_id_to_index(selected_task_id, id)]["is_selected_child?"] == true
  end

  def selected_task
    i = 0
    @tasks.each_with_index do |task, index|
      is_selected?(task['id']) ? i = index : nil
    end
    i
  end

  def selected_task_id
    i = 0
    @tasks.each_with_index do |task, _index|
      is_selected?(task['id']) ? i = task['id'] : nil
    end
    i
  end

  def selected_child_name
    @tasks[selected_task]['child_tasks'][selected_child_task]['description']
  end

  def selected_child_task
    i = 0
    @tasks[selected_task]['child_tasks'].each_with_index do |task, index|
      task['is_selected_child?'] ? i = index : nil
    end
    i
  end

  def selected_child_task_id
    i = 0
    @tasks[selected_task]['child_tasks'].each_with_index do |task, _index|
      is_selected_child?(task['id']) ? i = task['id'] : nil
    end
    i
  end

  def select_task(id)
    @tasks.each { |t| t['id'] == id ? t['is_selected?'] = true : nil }
  end

  def select_child_task(pid, cid)
    @tasks[id_to_index(pid)]['child_tasks'].each { |t| t['id'] == cid ? t['is_selected_child?'] = true : nil }
  end

  def deselect_task(id)
    @tasks.each { |t| t['id'] == id ? t['is_selected?'] = false : nil }
  end

  def deselect_child_task
    @tasks[selected_task]["child_tasks"].each { |t| t['is_selected'] == true ? t['is_selected?'] = false : nil }
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

  def is_complete?(answer)
    @tasks[id_to_index(answer)]['is_complete?']
  end

  def is_child_complete?
    @tasks[selected_task]['child_tasks'][selected_child_task]['is_complete?']
  end

  def check_for_complete_parent
    complete = true
    @tasks[selected_task]['child_tasks'].each do |child_task|
      child_task['is_complete?'] == true ? nil : complete = false
    end
    complete
  end

  def count_tasks
    amount_of_tasks = @tasks.length
    @tasks.each do |task|
      task["is_parent?"] ? amount_of_tasks -= 1 : nil
      amount_of_tasks += task['child_tasks'].length
    end
    amount_of_tasks
  end

  def count_complete_tasks
    complete_tasks = 0
    @tasks.each do |task|
      task['is_parent?'] == false && task["is_complete?"] == true ? complete_tasks += 1 : nil 
      task['child_tasks'].each do |child_task|
        child_task["is_complete?"] == true ? complete_tasks += 1 : nil
      end
    end
    complete_tasks
  end
end
