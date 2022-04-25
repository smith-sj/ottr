require_relative '../list'

describe List do
  context "When a list object's tasks contain 3 items:" do
    before(:each) do
      @list = List.new
      @list.instance_variable_set(:@tasks, [{ 'id' => 6,
                                              'description' => 'Do the laundry',
                                              'is_complete?' => false,
                                              'is_parent?' => false,
                                              'is_selected?' => false,
                                              'child_tasks' => [] },
                                            {
                                              'id' => 8,
                                              'description' => 'Go for walk',
                                              'is_complete?' => false,
                                              'is_parent?' => false,
                                              'is_selected?' => false,
                                              'child_tasks' => []
                                            },
                                            {
                                              'id' => 4,
                                              'description' => 'Wash the car',
                                              'is_complete?' => false,
                                              'is_parent?' => false,
                                              'is_selected?' => false,
                                              'child_tasks' => []
                                            }])
    end

    it 'should return array of hashes containing {task_description => id}' do
      expect(@list.list_task_descriptions).to eq([
                                                   { name: 'Do the laundry', value: 6 },
                                                   { name: 'Go for walk', value: 8 },
                                                   { name: 'Wash the car', value: 4 }
                                                 ])
    end

    it 'should return array of task ids' do
      expect(@list.task_ids).to eq([6, 8, 4])
    end

    it 'should return a unique id that is 1 larger than the largest id' do
      expect(@list.unique_id).to eq(9)
    end

    it 'should take a description and add a new task to @tasks array' do
      @list.add_task('Mow the lawn')
      expect(@list.list_task_descriptions).to eq([
                                                   { name: 'Do the laundry', value: 6 },
                                                   { name: 'Go for walk', value: 8 },
                                                   { name: 'Wash the car', value: 4 },
                                                   { name: 'Mow the lawn', value: 9 }
                                                 ])
    end

    it "should take an id and return the associated task's index" do
      expect(@list.id_to_index(6)).to eq(0)
      expect(@list.id_to_index(8)).to eq(1)
      expect(@list.id_to_index(4)).to eq(2)
    end
  end

  context "When one of the list's task's is selected it should:" do
    before(:each) do
      @list = List.new
      @list.instance_variable_set(:@tasks, [{
                                    'id' => 6,
                                    'description' => 'Do the laundry',
                                    'is_complete?' => false,
                                    'is_parent?' => false,
                                    'is_selected?' => false
                                  },
                                            {
                                              'id' => 8,
                                              'description' => 'Go for walk',
                                              'is_complete?' => false,
                                              'is_parent?' => false,
                                              'is_selected?' => true
                                            },
                                            {
                                              'id' => 4,
                                              'description' => 'Wash the car',
                                              'is_complete?' => false,
                                              'is_parent?' => false,
                                              'is_selected?' => false
                                            }])
    end

    it 'should take an id and return true if task is selected' do
      expect(@list.is_selected?(8)).to eq(true)
    end

    it 'should take an id and return false if task not selected' do
      expect(@list.is_selected?(6)).to eq(false)
    end

    it "should take an id and change the associated task's 'selected' value to true" do
      @list.select_task(4)
      expect(@list.is_selected?(4)).to eq(true)
    end

    it "should take an id and change the associated task's 'selected' value to false" do
      @list.deselect_task(8)
      expect(@list.is_selected?(8)).to eq(false)
    end
  end
end
