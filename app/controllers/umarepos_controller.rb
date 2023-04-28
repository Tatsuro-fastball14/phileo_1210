class UmareposController < ApplicationController
  def new
    @umarepos = Umarepo.new
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

  def umarepos_params
    params.require(:umarepo).permit(:title,:curator,:comment,:cook_id,  images: [])
  end
end
