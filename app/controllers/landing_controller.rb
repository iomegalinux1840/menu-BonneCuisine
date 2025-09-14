class LandingController < ApplicationController
  def index
    @restaurants = Restaurant.active.limit(10)
    # For now, redirect to the default restaurant
    # Later this will be a proper landing page
    redirect_to '/r/la-bonne-cuisine'
  end
end