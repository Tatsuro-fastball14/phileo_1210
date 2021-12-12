class MapsController < ApplicationController
  class MapsController < ApplicationController
    def index
        @maps = Map.all
        @map = Map.new
    end

    def create
        map = Map.new(map_params)
        if map.save
            redirect_to :action => "index"
        else
            redirect_to :action => "index"
        end
    end

    def destroy
        map = Map.find(params[:id])
        map.destroy
        redirect_to action: :index
    end

    private
    def map_params
    params.require(:map).permit(:address, :latitude, :longitude)
    end
end
end
