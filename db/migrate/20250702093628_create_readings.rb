class CreateReadings < ActiveRecord::Migration[8.0]
  def change
    create_table :readings do |t|
      t.float :current_reading
      t.timestamps
    end
  end
end
