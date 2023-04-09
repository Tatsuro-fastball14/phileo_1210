class UmareposController < ApplicationController


  def new
    @umarepos = Umarepo.new
    cook_id = @cook.id
    
  end

  def create
      @umarepos = Umarepo.new(umarepos_params)
     
      
    if
     @umarepos.save!
      redirect_to root_path
    else
      render :new
    end

  end

  


   def umarepos_params
    params.require(:umarepo).permit(:title,:curator,:comment,:cook_id,  images: [])
  end
  






end
