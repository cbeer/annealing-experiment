class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.string :location
      t.string :needs
      t.datetime :time
      t.references :schedule
      t.references :event
      t.references :user
      t.references :room
    end
  end
end
