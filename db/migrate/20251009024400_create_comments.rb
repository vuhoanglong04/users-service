class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.timestamp :deleted_at
      t.string :ancestry
      t.timestamps
    end
    add_index :comments, :ancestry
  end
end
