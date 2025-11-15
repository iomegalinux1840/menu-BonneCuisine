class Admin::LayoutsController < Admin::BaseController
  def show
  end

  def update
    if @restaurant.update(layout_params)
      redirect_to restaurant_admin_layout_path(restaurant_slug: @restaurant.slug),
                  notice: 'Mise en page mise à jour avec succès.'
    else
      flash.now[:alert] = 'Impossible de mettre à jour la mise en page. Veuillez vérifier les informations.'
      render :show, status: :unprocessable_entity
    end
  end

  private

  def layout_params
    params.require(:restaurant).permit(
      :menu_image_size,
      :menu_grid_columns,
      :message_of_the_day,
      :menu_display_style,
      :menu_font_size,
      :menu_font_color,
      :menu_background_color,
      :menu_accent_color
    )
  end
end
