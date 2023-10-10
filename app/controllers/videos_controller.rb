class VideosController < ApplicationController
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

  def destroy
    @cook = Cook.find(params[:id])
    @cook.delete_videos
    redirect_to cooks_path(@cook)
  end


  def videos_params
    params.require(:video).permit(images:[],videos:[])
  end
end

