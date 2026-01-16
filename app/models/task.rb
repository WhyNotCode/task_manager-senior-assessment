#== Schema Information
# Table name: tasks
#  id            :bigint           not null, primary key
#  title         :string           not null
#  description   :text
#  completed_at  :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null       

# I realised that using a 'completed' boolean field can lead to data inconsistency.
# Instead, I use 'completed_at' datetime field to track when a task was completed. 
# It is also more informative as it tells us when the task was completed.


class Task < ApplicationRecord
  # Validations
  validates :title, presence: true
  validates :title, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }

  # Scopes for easy querying
  scope :completed, -> { where.not(completed_at: nil) }
  scope :incomplete, -> { where(completed_at: nil) }

  def completed
    completed_at.present?
  end
  
  def completed=(value)
    if value == "1" || value == true
      self.completed_at ||= Time.current
    else
      self.completed_at = nil
    end
  end

  def self.completion_percentage
    return 0 if none?
    (completed.count.to_f / count * 100).round
  end
  
  # Helper methods
  def completed?
    completed_at.present?
  end
  
  def complete!
    update(completed_at: Time.current)
  end
  
  def incomplete!
    update(completed_at: nil)
  end
  
  def toggle!
    update(completed: !completed)
  end

  # For statistics in our view
  def completion_percentage
    return 0 if Task.none?
    (Task.completed.count.to_f / Task.count * 100).round
  end
end