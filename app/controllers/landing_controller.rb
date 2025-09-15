class LandingController < ApplicationController
  def index
    @restaurants = Restaurant.active
  end
end