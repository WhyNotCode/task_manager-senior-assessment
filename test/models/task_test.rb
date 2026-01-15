require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "should not save task without title" do
    task = Task.new(description: "A task without a title")
    assert_not task.save, "Saved the task without a title"
  end
  
  test "should save task with valid attributes" do
    task = Task.new(title: "Test Task", description: "Test description")
    assert task.save
  end
  
  test "task completion methods work correctly" do
    task = Task.create(title: "Test Task")
    
    # Initially it should start as incomplete
    assert_not task.completed?
    
    # Complete the task
    task.complete!
    assert task.completed?
    assert task.completed_at.present?
    
    # Mark as incomplete again
    task.incomplete!
    assert_not task.completed?
    assert_nil task.completed_at
  end
  
  test "scopes work correctly" do
    # Create some test tasks
    completed_task = Task.create(title: "Completed", completed_at: Time.current)
    incomplete_task = Task.create(title: "Incomplete")
    
    # Test scopes
    assert_includes Task.completed, completed_task
    assert_not_includes Task.completed, incomplete_task
    
    assert_includes Task.incomplete, incomplete_task
    assert_not_includes Task.incomplete, completed_task
  end
end