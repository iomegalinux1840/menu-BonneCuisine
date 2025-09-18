class LandingController < ApplicationController
  def index
    @restaurants = Restaurant.active
    @sample_restaurant = @restaurants.first
  end
end
