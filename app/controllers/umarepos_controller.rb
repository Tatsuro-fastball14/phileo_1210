class UmareposController < ApplicationController


  def new
    @umarepo = Umarepo.new
   
  end

  def create
     @umarepo = Umarepo.new(umarepos_params)
     
    if @umarepo.save!
      redirect_to root_path
    else
      render :new
    end

  end




   def umarepos_params
    params.require(:umarepo).permit(:title, :coment, images: [])
  end






end
