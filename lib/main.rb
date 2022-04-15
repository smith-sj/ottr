require "tty-prompt"
require "json"


# puts '  welcome to ottr'
# choices = ['do the dishes', 'walk the dog', 'have a shower']
# option = prompt.select("", choices)
# puts option

# def json_to_array(file)
#     JSON.parse!(file)
# end
# class List

#     attr_reader :tasks

#     def initialize
#         @tasks = []
#     end

#     def import_tasks(file)
#         @tasks.push(file)
#     end

# end

# prompt = TTY::Prompt.new
# ottr = json_to_array(File.read('.ottr.json'))
# descriptions = ottr.map {|o| o["description"]}
# list = List.new

# if ottr.length > 0
#     list.import_tasks(descriptions)
# end

# option = prompt.select("", list.tasks)

