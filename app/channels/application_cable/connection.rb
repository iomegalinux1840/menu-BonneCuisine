module ApplicationCable
  class Connection < ActionCable::Connection::Base
    # No authentication needed for public menu updates
  end
end