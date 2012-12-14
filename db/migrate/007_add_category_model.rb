class AddCategoryModel < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
    end

    change_table :assets do |t|
      t.integer :category_id
    end

    Category.create('name' => 'default')

    Asset.all.each do |asset|
      if asset.category.present?
        c = Category.find_by_name(asset.category) || Category.create('name' => asset.category)
      else
        c = Category.find_by_name('default')
      end
      asset.category_id = c.id
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
