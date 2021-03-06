class Admin::AssetsController < Admin::ResourceController
  paginate_models(:per_page => 50)
  
  def index
    assets = Asset.scoped({:order => "title"})
    
    @term = params[:search] || ''
    assets = assets.matching(@term) if @term && !@term.blank?
    assets = assets.matching_category(params[:category_id]) if params[:category_id].present?
    
    @types = params[:filter] || []
    if @types.include?('all')
      params[:filter] = nil
    elsif @types.any?
      assets = assets.of_types(@types)
    end
    
    @assets = paginated? ? assets.paginate(pagination_parameters) : assets.all
    respond_to do |format|
      format.html { render }
      format.js { 
        @page = Page.find_by_id(params[:page_id])
        render :partial => 'asset_table', :locals => {:with_pagination => !!@page, :list_view => params[:list_view]}
      }
    end
  end
  
  def create
    @assets, @page_attachments = [], []
    params[:asset][:asset].to_a.each do |uploaded_asset|
      @asset = Asset.create(:asset => uploaded_asset, :title => params[:asset][:title], :caption => params[:asset][:caption], :slug => params[:asset][:slug], :category_id => params[:asset][:category_id])
      if params[:for_attachment]
        @page = Page.find_by_id(params[:page_id]) || Page.new
        @page_attachments << @page_attachment = @asset.page_attachments.build(:page => @page)
      end
      @assets << @asset
    end
    if params[:for_attachment]
      render :partial => 'admin/page_attachments/attachment', :collection => @page_attachments
    else 
      response_for :create
    end
  end

  def update
    if params[:id]
      @asset = Asset.find(params[:id])

      if params[:asset][:asset]
        @asset.update_attributes(params[:asset])
      else
        new_attachment = params[:asset][:asset] || File.new(@asset.asset.path)
        @asset.asset.destroy

        @asset.category = Category.find(params[:asset][:category_id]) # Category must be saved prior to Asset so the file is rewritten to its new location correctly.
        @asset.save
        @asset.update_attributes(params[:asset].merge('asset' => new_attachment))
      end
    end
    redirect_to admin_assets_path
  end

  def refresh
    if params[:id]
      @asset = Asset.find(params[:id])
      @asset.asset.reprocess!
      flash[:notice] = t('clipped_extension.thumbnails_refreshed')
      redirect_to edit_admin_asset_path(@asset)
    else
      render
    end
  end
  
  only_allow_access_to :regenerate,
    :when => [:admin],
    :denied_url => { :controller => 'admin/assets', :action => 'index' },
    :denied_message => 'You must have admin privileges to refresh the whole asset set.'

  def regenerate
    Asset.all.each { |asset| asset.asset.reprocess! }
    flash[:notice] = t('clipped_extension.all_thumbnails_refreshed')
    redirect_to admin_assets_path
  end
  
end
