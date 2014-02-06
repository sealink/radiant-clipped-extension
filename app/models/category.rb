class Category < ActiveRecord::Base

  DEFAULT_CATEGORY = 'default'
  PAGE_ASSET_CATEGORY = 'Page Asset'
  PROTECTED_CATEGORIES = [DEFAULT_CATEGORY, PAGE_ASSET_CATEGORY]
  before_destroy :reattach_assets_if_destroyable
  before_update :updatable?

  named_scope :ordered, :order => :name

  def reattach_assets_if_destroyable
    raise ActiveRecord::ActiveRecordError, "You cannot delete this category." if PROTECTED_CATEGORIES.include?(name)

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
    raise ActiveRecord::ActiveRecordError, "You cannot modify this category." if PROTECTED_CATEGORIES.include?(name_was)
  end

end
