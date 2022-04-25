require_relative '../lib/menu'

describe Menu do
  context 'A new menu object' do
    before(:each) do
      @menu = Menu.new
      @tasks = [{ 'Do the laundry' => 6 },
                { 'Go for walk' => 8 },
                { 'Wash the car' => 4 },
                { 'Mow the lawn' => 9 }]
    end

    it 'if given a list of task:value hashes, it should merge with default options' do
      @menu.populate_options(@tasks)
      expect(@menu.options).to eq([
                                    { 'Do the laundry' => 6 },
                                    { 'Go for walk' => 8 },
                                    { 'Wash the car' => 4 },
                                    { 'Mow the lawn' => 9 },
                                    { 'Add task' => :ADD },
                                    { 'Quit' => :QUIT }
                                  ])
    end

    it 'should construct a TTY prompt containing @options' do
    end
  end
end
