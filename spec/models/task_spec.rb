require 'rails_helper'

RSpec.describe Task, type: :model do
  describe "validations" do
    it "requires a title" do
      task = Task.new(title: nil, description: "Some description")
      expect(task).not_to be_valid
      expect(task.errors[:title]).to include("can't be blank")
    end

    it "allows a task with just a title" do
      task = Task.new(title: "Buy milk")
      expect(task).to be_valid
    end

    it "rejects titles that are too long" do
      long_title = "A" * 101
      task = Task.new(title: long_title)
      expect(task).not_to be_valid
    end

    it "rejects descriptions that are too long" do
      long_description = "A" * 501
      task = Task.new(title: "Write report", description: long_description)
      expect(task).not_to be_valid
    end
  end

  describe "completion logic" do
    let(:task) { Task.create(title: "Test task") }
    
    it "starts as incomplete" do
      expect(task).not_to be_completed
      expect(task.completed_at).to be_nil
    end

    it "can be marked as complete" do
      task.complete!
      expect(task).to be_completed
      expect(task.completed_at).to be_present
      expect(task.completed_at).to be_within(1.second).of(Time.current)
    end

    it "can be marked as incomplete again" do
      task.complete!
      expect(task).to be_completed
      
      task.incomplete!
      expect(task).not_to be_completed
      expect(task.completed_at).to be_nil
    end

    it "tracks when it was completed" do
      # Use Timecop for precise time testing
      completion_time = Time.current
      Timecop.freeze(completion_time) do
        task.complete!
        # We care that it was set to the current time, not the exact nanosecond
        expect(task.completed_at).to be_within(1.second).of(Time.current)
        expect(task.completed_at.to_i).to eq(completion_time.to_i) # Same second
      end
    end
  end

  describe "scopes for querying" do
    before do
      # Create a mix of completed and incomplete tasks
      @completed_task = Task.create(title: "Done task")
      @completed_task.complete!
      
      @incomplete_task = Task.create(title: "Todo task")
    end

    it "finds completed tasks" do
      completed_tasks = Task.completed
      expect(completed_tasks).to include(@completed_task)
      expect(completed_tasks).not_to include(@incomplete_task)
    end

    it "finds incomplete tasks" do
      incomplete_tasks = Task.incomplete
      expect(incomplete_tasks).to include(@incomplete_task)
      expect(incomplete_tasks).not_to include(@completed_task)
    end

    it "calculates completion percentage correctly" do
      # With 1 completed out of 2 total = 50%
      expect(Task.completion_percentage).to eq(50)
    end

    it "returns 0% when there are no tasks" do
      Task.destroy_all
      expect(Task.completion_percentage).to eq(0)
    end
  end
end