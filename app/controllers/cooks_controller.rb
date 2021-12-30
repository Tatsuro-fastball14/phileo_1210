class CooksController < ApplicationController
  before_action :search_product, only: [:index, :search]
  before_action :basic_auth, only: [:new]

  def index
    @cooks = Cook.all
  end

  def new
    @cook = Cook.new
  end

  def create
    @cook = Cook.new(cooks_params)
    if @cook.save
      redirect_to root_path
    else
      render :new
    end
  end

  def search
    @results = @p.result.includes(:category)
  end

  private

  def cooks_params
<<<<<<< Updated upstream
    params.require(:cook).permit(:image, :title, :store, :cooksentence)
=======
    params.require(:cook).permit(:title, :store, :cooksentence,images: [])
>>>>>>> Stashed changes
  end

  def search_cook
    @p = cook.ransack(params[:q])
  end
end

private

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == 'admin' && password == '2222'
    end
  end