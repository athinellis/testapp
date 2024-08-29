class ProductsDatatable
  delegate :params,
           :h,
           :link_to,
           :number_to_currency,
           :product_path,
           :edit_product_path,
           :logged_in_admin?,
           :logged_in_storehouse?,
           :logged_in_accountant?,
           :logged_in_salesman_trimed?,
           :logged_in_headofDesign?,
           :logged_in_designer?,
           :image_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: products.total_entries,
      iTotalDisplayRecords: products.total_entries,
      aaData: data
    }
  end

  private


  def data
    products.each_with_index.map do |product, index|
      [
        index + 1,
        product.name,
        product.price

      ]
    end
  end

  def products
    @products ||= fetch_products
  end

  def fetch_products
    products = User.all.order("#{sort_column} #{sort_direction}")
    products = products.page(page).per_page(per_page)


    if params[:productDescription].present?
      products = products.where('name like :search', search: "%#{params[:productDescription]}%")
    end


    products
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name price created_at] # Οι στήλες που επιτρέπεται να ταξινομηθούν
    columns[params.dig(:order, 0, :column).to_i] || 'name'
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end