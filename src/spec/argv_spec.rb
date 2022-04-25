require_relative '../process_argv'

include ProcessARGV

describe ProcessARGV do
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
                                              'child_tasks' => [
                                                {
                                                  'id' => 10,
                                                  'description' => 'Put on walking shoes',
                                                  'is_complete?' => false,
                                                  'is_selected_child?' => false
                                                },
                                                {
                                                  'id' => 11,
                                                  'description' => 'Tie up laces',
                                                  'is_complete?' => false,
                                                  'is_selected_child?' => false
                                                },
                                                {
                                                  'id' => 13,
                                                  'description' => 'Walk out the door',
                                                  'is_complete?' => false,
                                                  'is_selected_child?' => false
                                                }
                                              ]
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

    it 'when given list and index it should return true if task index exists in list' do
      expect(task_exist(@list, 2)).to eq(true)
    end

    it 'when given list and index it should return false if task index does not exist in list' do
      expect(task_exist(@list, 5)).to eq(false)
    end

    it 'when given list, index and child index, it should return true if child index exists in list' do
      expect(child_exist(@list, 2, 3)).to eq(true)
    end

    it 'when given list, index and child index, it should return false if child index does not exist in list' do
      expect(child_exist(@list, 2, 6)).to eq(false)
    end
  end
end
