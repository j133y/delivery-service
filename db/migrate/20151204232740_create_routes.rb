class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.string :origin
      t.string :destination
      t.integer :distance
      t.references :map, index: true

      t.timestamps null: false
    end
    add_foreign_key :routes, :maps
  end
end
