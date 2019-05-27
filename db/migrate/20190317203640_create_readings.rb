class CreateReadings < ActiveRecord::Migration[5.2]
  def change
    create_table :readings do |t|
      t.references :thermostat, foreign_key: true
      t.integer :sequence_number
      t.float :temperature
      t.float :humidity
      t.float :battery_charge

      t.timestamps
    end
  end
end
