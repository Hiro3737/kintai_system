class AddWorkToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :basic_work_time, :datetime
    add_column :users, :specified_work_time, :datetime
  end
end
