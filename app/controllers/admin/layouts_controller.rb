class Admin::LayoutsController < Admin::BaseController
  def show
  end

  def update
    if @restaurant.update(layout_params)
      broadcast_layout_update
      redirect_to restaurant_admin_layout_path(restaurant_slug: @restaurant.slug),
                  notice: 'Mise en page mise à jour avec succès.'
    else
      flash.now[:alert] = 'Impossible de mettre à jour la mise en page. Veuillez vérifier les informations.'
      render :show, status: :unprocessable_entity
    end
  end

  private

  def layout_params
    params.require(:restaurant).permit(:menu_image_size, :menu_grid_columns, :message_of_the_day)
  end

  def broadcast_layout_update
    MenuChannel.broadcast_to(@restaurant, { action: 'refresh', source: 'layout' })
  rescue => e
    Rails.logger.warn "Layout broadcast failed: #{e.message}"
  end
end
