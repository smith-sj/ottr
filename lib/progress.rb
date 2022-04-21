require 'tty-progressbar'
require 'pastel'

class Progress

    def initialize(list)
        pastel = Pastel.new
        green = pastel.on_green(" ")
        red = pastel.on_black(" ")    
        bar = TTY::ProgressBar.new(
            ":percent [:bar]\n:current/:total completed\n", 
            total: list.count_tasks, 
            width: 10, 
            complete: green,
            incomplete: red)
        bar.advance(list.count_complete_tasks)
    end
end
