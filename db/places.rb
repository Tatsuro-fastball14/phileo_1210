def self.search(search)
  if search
    Place.where('title LIKE(?)', "%#{search}%")
  else
    Place.all
  end
end