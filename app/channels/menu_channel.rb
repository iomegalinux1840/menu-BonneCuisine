class MenuChannel < ApplicationCable::Channel
  def subscribed
    restaurant = Restaurant.find_by(id: params[:restaurant_id])

    if restaurant
      stream_for restaurant
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
