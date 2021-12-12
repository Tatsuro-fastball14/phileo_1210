class Map < ApplicationRecord
  after_validation :geocode

  private
  def geocode
    uri = uri.escape(http://maps.google.com/maps/api/geocode/json?address"+self.address.gsubkey=AIzaSyAc8ucfbF9aY5Jn9VehhJZ852fopENuQT)
    res = HTTP.get(uri).to_s
    response = json.parse(res)
    self.latitude = response["results"][0]["geometry"]["location"]["lat"]
    self.longitude = response["results"][0]["geometry"]["location"]["lng"]
  end
end
