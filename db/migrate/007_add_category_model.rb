class AddCategoryModel < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
    end

    change_table :assets do |t|
      t.integer :category_id
    end

    Asset.all.each do |asset|
      c = Category.create('name' => asset.category)
      asset.category = c
      asset.save
    end

    change_table :assets do |t|
      t.remove :category
    end
  end

  def self.down
    drop_table :categories

    change_table :assets do |t|
      t.remove :category_id
      t.string :category
    end
  end
end
