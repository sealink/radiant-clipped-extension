class Category < ActiveRecord::Base

  DEFAULT_CATEGORY = 'default'
  before_destroy :reattach_assets_if_destroyable
  before_update :updatable?

  def reattach_assets_if_destroyable
    raise ActiveRecord::ActiveRecordError, "You cannot delete the default category." if name == DEFAULT_CATEGORY

    Asset.all(:conditions => ["category_id = ?", id]).each do |asset|
      new_attachment = File.new(asset.asset.path)
      asset.asset.destroy

      asset.category = Category.find_by_name(DEFAULT_CATEGORY) # Must be set prior to asset so file is rewritten correctly.
      asset.save

      asset.asset = new_attachment
      asset.save
    end
  end

  def updatable?
    raise ActiveRecord::ActiveRecordError, "You cannot modify the default category." if name_was == DEFAULT_CATEGORY
  end

end
