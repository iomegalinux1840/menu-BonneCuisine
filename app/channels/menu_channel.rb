class MenuChannel < ApplicationCable::Channel
  def subscribed
    stream_from "menu_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end