class LettersController < ApplicationController

  def index
    @letters =  letter.all
  end
end
