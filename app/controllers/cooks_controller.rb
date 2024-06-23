class CooksController < ApplicationController
  before_action :authenticate_user!, except: [:index,:search]
  before_action :search_cook, only: [:index, :search]
  before_action :basic_auth, only: [:new]
  before_action :set_cook, only: [:edit, :show,:update,:destroy]

  def index
    @cooks =  Cook.all
    @videos=  Cook.all
    render json: @cooks
  end
  

  def new
    @cook = Cook.new
    @umarepo = Umarepo.new
  end

  def create
    @cook = Cook.new(cooks_params)
    if  @cook.save
        redirect_to root_path
    else
        render :new
    end
  end

  def edit
  end

  def update
    if  @cook.update(cooks_params)
        redirect_to cook_path
    else
        render :edit
    end 
  end

  def destroy
    @cook.destroy
    redirect_to root_path
  end

  

  def show
    redirect_to orders_path unless current_user.subscriber?
    @cook = Cook.find(params[:id])
    @umarepos = @cook.umarepos
    @umarepo =Umarepo.new
  end

  def search
    @p = Cook.ransack(params[:q])
    @cooks = @p.result
    @cooks = Cook.all.page(params[:page])  
  end

  private

  def cooks_params
    params.require(:cook).permit(:store_catchcopy, :sentence, :address, :phone_number,:store,:category,:lat,:lng,:order,images:[],videos:[])
  end

  def videos_params
    params.require(:cook).permit(images:[],videos:[])
  end

  def search_cook
    @p = Cook.ransack(params[:q])
  end

  

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
    username == 'admin' && password == '1414'
    end
  end

  def set_cook
    @cook = Cook.find(params[:id])
  end

  private

  def favorite_params
    params.require(:favorite).permit(:umarepo_id, :user_id)
  end
end

 