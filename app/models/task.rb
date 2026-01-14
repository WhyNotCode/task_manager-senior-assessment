class Task < ApplicationRecord
  validates :title, presence: true
  
  scope :completed, -> { where(completed: true) }
  scope :incomplete, -> { where(completed: false) }
  
  def toggle!
    update(completed: !completed)
  end
end