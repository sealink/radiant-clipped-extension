class AssetUuid < ActiveRecord::Migration
  def self.up
    add_column :assets, :uuid, :string
    Asset.reset_column_information
    Asset.scoped(:conditions => "uuid IS NULL").each do |a|
      Asset.update_all({:uuid => UUIDTools::UUID.timestamp_create.to_s}, {:id => a.id})
    end
  end

  def self.down
    remove_column :assets, :uuid
  end
end
