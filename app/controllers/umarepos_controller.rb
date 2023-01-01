class UmareposController < ApplicationController


  def new
    @umarepos = Umarepo.new
    
  end

  def create
      @umarepos = Umarepo.new(umarepos_params)
      @umarepos.cook_id = cook.id
    
     
    if @umarepos.save!
      redirect_to root_path
    else
      render :new
    end

  end

  


   def umarepos_params
    params.require(:umarepo).permit(:title, :comment, cook_id: cook.id, images: [])
  end
  






end
