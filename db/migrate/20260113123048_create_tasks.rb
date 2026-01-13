class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    # Only create table if it doesn't exist
    unless table_exists?(:tasks)
      create_table :tasks do |t|
        t.string :title
        t.text :description
        t.boolean :completed, default: false

        t.timestamps
      end
    end
  end
end
