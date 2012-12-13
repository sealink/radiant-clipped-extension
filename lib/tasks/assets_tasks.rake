namespace :assets do

  desc "Sets default category and slug for already existing assets (which don't have them set), and moves them to their proper place."
  task :set_default_category_and_slug => :environment do
    old_assets = Asset.all(:conditions => ["category IS NULL OR category = ? OR slug IS NULL OR slug = ?", '', ''])
    old_assets.each do |asset|
      asset.category ||= 'default'
      asset.slug ||= asset.title.parameterize
      asset.save

      old_path = Rails.root.to_s << "/public/system/assets/#{asset.id}/original/#{asset.asset_file_name}"
      begin
        file = File.new(old_path)
        if file
          asset.asset.destroy
          asset.update_attributes('asset' => file)
        end
      rescue
        puts "#{old_path} was not updated as the file was not found on disk"
      end
    end
  end

end
