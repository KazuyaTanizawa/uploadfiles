class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :filename
      t.string :index
      t.references :book

      t.timestamps
    end
    add_index :images, :book_id
  end
end
