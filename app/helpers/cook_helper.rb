module CookHelper

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
 end


 def store_location
    session[:forwarding_url] = request.original_url if request.get?
 end

end
