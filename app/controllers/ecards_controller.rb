class EcardsController < ApplicationController
  def index
    @ecards = Ecard.all
  end
  
  def new
    
  end
  
  def edit
    @ecard = Ecard.find(params[:id])
  end
  
  def update
    e = Ecard.find(params[:id])
    e.update_attributes(
      :title => params[:title],
      :description => params[:description],
      :price => params[:price],
      :image => params[:image],
      :filename => params[:filename],
      :video_file => params[:video_file]
    )
    redirect_to :action => 'index'
  end
  
  def show
    @ecard = Ecard.find(params[:id])
  end 
  
  def create
    e = Ecard.create(
      :title => params[:title],
      :description => params[:description],
      :price => params[:price],
      :image => params[:image],
      :filename => params[:filename],
      :video_file => params[:video_file]
    )
    redirect_to :action => "index"
  end
  
  def destroy
    #should implement destroy (ignacio)
    Ecard.delete(params[:id])
    redirect_to :action => "index"
  end
end
