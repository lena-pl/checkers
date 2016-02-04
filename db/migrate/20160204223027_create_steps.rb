class CreateSteps < ActiveRecord::Migration
  def change
    create_table :steps do |t|
      t.integer :kind, null: false
      t.references :player, index: true, null: false
      t.timestamps null: false
    end
  end
end
