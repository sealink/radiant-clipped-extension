namespace :assets do

  desc "Sets default category and slug for already existing assets (which don't have them set), and moves them to their proper place."
  task :set_default_category_and_slug => :environment do
    old_assets = Asset.all(:conditions => ["category_id IS NULL OR category_id = ? OR slug IS NULL OR slug = ?", '', ''])
    old_assets.each do |asset|
      asset.category_id ||= Category.find_by_name('default').id
      asset.slug ||= asset.title.try(:parameterize) || 'default-slug'
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

  desc "Import assets into the database from files within a directory."
  task :import => :environment do
    puts "\nBefore beginning, move all assets you wish to import into a directory named assets_to_import."
    puts "Inside this directory, place the assets into separate subfolders if you wish them to be categorized."
    puts "Continue with import? (y/n)"
    response = STDIN.gets.chomp
    return unless ['y', 'Y', 'yes', 'Yes'].include?(response)

    puts "Enter the full path of the assets_to_import directory on the file system: (e.g. /users/JohnDoe/assets_to_import)"
    path = STDIN.gets.chomp

    assets_to_import = Dir["#{path}/**/*.jpg"]
    assets_to_import.each do |asset|
      file = File.new(asset)
      title = (asset.match /([^\/]*).jpg$/)[1] # all characters between last forward slash and ending .jpg i.e. filename
      category_name_match = (asset.match /assets_to_import\/([^\/]*)\//) # name of directory below assets_to_import
      category_name = if category_name_match
        category_name_match[1]
      else
        'default'
      end

      if Category.find_by_name(category_name)
        category = Category.find_by_name(category_name)
      else
        category = Category.create(:name => category_name)
        puts "Category created! Name: #{category_name}"
      end

      asset = Asset.create(:title => title, :category => category)
      puts "Asset created! Title: #{title}, ID: #{asset.id}"
      asset.update_attributes('asset' => file)
    end
  end

end
