 def index
    @videos=  Video.all
    render json: @cooks
  end


def show
  @video = Video.find(params[:id])
end

def edit
  @video = Video.find(params[:id])
end
#destroy actionしているが、binding.pryがかからない
 def destroy
  @video = Video.find(params[:id])
  biding.pry
  @video.destroy
  redirect_to videos_path
end


def videos_params
  params.require(:video).permit(images:[],videos:[])
end

