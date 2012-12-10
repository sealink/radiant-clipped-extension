class AddSlugAndCategoryToAsset < ActiveRecord::Migration
  def self.up
    change_table :assets do |t|
      t.string :slug
      t.string :category
    end
  end

  def self.down
    remove_column :assets, :slug
    remove_column :assets, :category
  end
end
