class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.string :title
      t.references :schedule
      t.datetime :starts_at
      t.datetime :ends_at
    end
  end
end
