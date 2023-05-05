class PlacesController < ApplicationController
  before_action :search_place, only: [:index, :search]
  before_action :basic_auth, only:[:new]

  def index
    @places = Place.all
  end

  def new
    @cook = Cook.new
    @cook = Cook.find(params[:cook_id])
  end

  def create
    @cook = Cook.new(cooks_params)
    if  @cook.save
        redirect_to root_path
    else
        render :new
    end
  end

  def search
    @cooks = @p.result.includes(:category)
    @places = Place.all
    @cooks = Cook.all
  end

  private

  def search_place
    @p = Place.ransack(params[:q])
  end
end
