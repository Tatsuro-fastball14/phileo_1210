module LegalHelper
  def legal(key, fallback: "")
    ENV.fetch(key.to_s.upcase, fallback)
  end
end
