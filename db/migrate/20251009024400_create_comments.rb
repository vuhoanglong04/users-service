class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :parent_id
      t.text :content, null: false

      t.timestamps
    end
    add_index :comments, :parent_id
    add_foreign_key :comments, :comments, column: :parent_id
  end
end
