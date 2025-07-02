class CreateTopUps < ActiveRecord::Migration[8.0]
  def change
    create_table :top_ups do |t|
      t.integer   :amount_cents
      t.float     :units
      t.datetime  :date
      t.timestamps
    end
  end
end
