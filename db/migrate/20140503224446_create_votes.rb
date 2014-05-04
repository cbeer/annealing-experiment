class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.references :user, index: true
      t.references :event, index: true
      t.integer :vote
    end
  end
end
