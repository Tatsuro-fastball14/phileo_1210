class UmareposController < ApplicationController


  def new
    @umarepos = Umarepo.new
      binding.pry
   
  end

  def create
     @umarepos = Umarepo.new(umarepos_params)
     binding.pry
     
    if @umarepos.save!
      redirect_to root_path
    else
      render :new
    end

  end

  


   def umarepos_params
    params.require(:umarepo).permit(:title, :comment, images: [])
  end






end
