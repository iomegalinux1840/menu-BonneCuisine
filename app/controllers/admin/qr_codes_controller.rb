class Admin::QrCodesController < Admin::BaseController
  def show
    @menu_url = public_menu_url_for(@restaurant)
    qr_code = RQRCode::QRCode.new(@menu_url)
    @qr_svg = qr_code.as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 10,
      standalone: true
    )
  end

  private

  def public_menu_url_for(restaurant)
    restaurant_menu_url(restaurant_slug: restaurant.slug)
  rescue NoMethodError
    url_for(controller: '/public_menus', action: :index, restaurant_slug: restaurant.slug, only_path: false)
  end
end
