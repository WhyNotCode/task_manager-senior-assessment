class ChangeCompletedToCompletedAtInTasks < ActiveRecord::Migration[7.1]
  def up
    add_column :tasks, :completed_at, :datetime
    
    # Migrate existing data: set completed_at for tasks that are marked as completed
    # We'll use the updated_at time as a reasonable completion check with timestamp
    Task.where(completed: true).find_each do |task|
      task.update(completed_at: task.updated_at)
    end
    
    # Remove the old column (after data migration)
    remove_column :tasks, :completed
  end
end