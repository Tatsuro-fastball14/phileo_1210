 def index
    @videos=  Cook.all
    render json: @cooks
  end
 

 def destroy
    @videos.destroy
    redirect_to root_path
  end


  

  def videos_params
    params.require(:cook).permit(images:[],videos:[])
  end
