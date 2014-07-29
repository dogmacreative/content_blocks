class CreateContentBlocks < ActiveRecord::Migration
  def change
    create_table :content_blocks do |t|
      t.string :name
      t.string :title
      t.text :content
      t.string :image
      t.string :link
      t.string :content_type
      t.string :content_id

      t.timestamps
    end
  end
end
