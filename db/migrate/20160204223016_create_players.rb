class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.integer :colour, null: false
      t.references :game, index: true, null: false
      t.timestamps null: false
    end
  end
end
