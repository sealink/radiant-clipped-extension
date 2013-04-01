class Admin::CategoriesController < Admin::ResourceController
  def index
    @categories = Category.ordered
    render 'index'
  end

  def update
    if params[:id]
      @category = Category.find(params[:id])
      old_path = Rails.root.to_s << "/public/assets/#{@category.name.downcase.parameterize}"
      @category.update_attributes(params[:category])
      move_assets_to_new_path(old_path)
    end
    redirect_to admin_categories_path
  end

  def destroy
    current_object.destroy
  rescue ActiveRecord::ActiveRecordError => e
    flash[:error] = e.message
  ensure
    redirect_to admin_categories_path
  end

  private

  def move_assets_to_new_path(old_path)
    src = old_path + '/.'  # All files within the old_path directory
    dest = Rails.root.to_s << "/public/assets/#{@category.name.downcase.parameterize}"
    FileUtils.mkdir_p(dest)
    FileUtils.cp_r(src, dest)
    FileUtils.rm_r(old_path)
  end

end

