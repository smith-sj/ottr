require "colorize"
require_relative 'json_handler'
include JSONHandler

class List

    attr_reader :tasks

    def initialize
        @tasks = []
        @selected_task = 0
    end

    def load_tasks
        @tasks = json_array(".ottr.json")
    end

    def write_tasks
        write_json('.ottr.json', @tasks)
    end

    # returns an array of hashes containing task description and ID
    # if the task is selected it is returned green
    def list_task_descriptions
        @tasks.each_with_index.map do |task, index|
            task["is_selected?"] ?
                {task["description"].colorize(:green) => task["id"]} :
                {task["description"] => task["id"]}
        end
    end

    def task_ids
        @tasks.map {|task| task["id"]}
    end

    def unique_id
        task_ids().max() + 1
    end

    def move_task(from,to)
        move_from = 0
        move_to = 0
        @tasks.each_with_index {|task, index| task["id"] == from ? move_from = index : 0}
        @tasks.each_with_index {|task, index| task["id"] == to ? move_to = index : 0}
        @tasks = @tasks.insert(move_to,@tasks.delete_at(move_from))
    end

    def add_task(description)
        @tasks.push({
            "id"=>unique_id(),
            "description"=>description,
            "status"=>"incomplete",
            "is_parent?"=>false})
    end

    def delete_task(target)
        @tasks.delete_if {|task| task["id"] == target}
    end

    def select_task(task)
        @selected_task = task
    end

    def id_to_index(id)
        index = 0
        tasks.each_with_index {|t, i| t["id"] == id ? index = i : nil}
        index
    end

    def select_task(id)
        tasks.each {|t| t["id"] == id ? t["is_selected?"] = true : nil}
    end

    def deselect_task(id)
        tasks.each {|t| t["id"] == id ? t["is_selected?"] = false : nil}
    end

end