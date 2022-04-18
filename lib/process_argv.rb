require_relative 'list.rb'

module ProcessARGV

    @@init_status = File.exist?('./.ottr.json')
    
    def self.init_status
        @@init_status
    end

    def initialize_ottr
        if @@init_status == true
            puts "already initialized"
        else
            List.new.write_tasks
            puts "ottr initialized"
        end
    end

end