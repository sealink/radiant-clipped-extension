class Admin::CategoriesController < Admin::ResourceController

  def index
    @categories = Category.all
    render 'index'
  end

  def destroy
    current_object.destroy
  rescue ActiveRecord::ActiveRecordError => e
    flash[:error] = e.message
  ensure
    redirect_to admin_categories_path
  end

end
