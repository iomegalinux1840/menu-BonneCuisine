class LandingController < ApplicationController
  def index
    @restaurants = Restaurant.active.limit(10)

    # Show list of restaurants or redirect to first one if it exists
    if @restaurants.any?
      render html: "<h1>Menu Platform</h1><p>Available Restaurants:</p><ul>#{@restaurants.map { |r| "<li><a href='/r/#{r.slug}'>#{r.name}</a></li>" }.join}</ul>".html_safe
    else
      render html: "<h1>Menu Platform</h1><p>No restaurants available yet.</p>".html_safe
    end
  end
end