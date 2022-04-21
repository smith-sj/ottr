require_relative 'list'

module ProcessARGV
  @@init_status = File.exist?('./.ottr.json')

  def initialize_ottr
    if @@init_status == true
      puts 'already initialized'
    else
      List.new.write_tasks
      puts 'ottr initialized'
    end
  end

  def self.init_status
    @@init_status
  end
end
