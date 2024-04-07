class UmareposController < ApplicationController
  before_action :set_umarepo, only: [:show, :edit, :update, :destroy, :favorite]
  

  def new
    @umarepo = Umarepo.new
    @cook = Cook.find(params[:cook_id])
  end

  def create
    cook = Cook.find(params[:cook_id])
   
    @umarepo = cook.umarepos.build(umarepos_params)  
    if
      @umarepo.save!
      redirect_to root_path
    else
      render :new
    end
  end

  def show
     @umarepo = Umarepo.find(params[:id]) 
  end

  def umarepos_params
    params.require(:umarepo).permit(:title,:curator,:comment,:cook_id,  images: [])
    

  end

  private

  def set_umarepo
    @umarepo = Umarepo.find(params[:id])
    rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Post not found."
  end
end

