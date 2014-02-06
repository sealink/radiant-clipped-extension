class AddPageAssetCategory < ActiveRecord::Migration
  def self.up
    Category.create('name' => 'Page Asset')
  end

  def self.down
    Category.delete_all("name = 'Page Asset'")
  end
end