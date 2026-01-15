class Task < ApplicationRecord
  # Validations
  validates :title, presence: true
  validates :title, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }

  # Scopes for easy querying
  scope :completed, -> { where.not(completed_at: nil) }
  scope :incomplete, -> { where(completed_at: nil) }

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