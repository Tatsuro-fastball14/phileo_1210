class CooksController < ApplicationController
  before_action :search_cook, only: [:index, :search]
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

  def show
    @cook = Cook.find(params[:id])
  end

  def search
    @p = Cook.ransack(params[:q])
    @cooks = @p.result
    
    
  end

  private

  def cooks_params
    params.require(:cook).permit(:image, :title, :store, :cooksentence)
  end

  def search_cook
    @p = Cook.ransack(params[:q])
  end
  private

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
    username == 'admin' && password == '2222'
    end

  end
      
end

