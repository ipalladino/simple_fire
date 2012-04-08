class SentEcardsController < ApplicationController
  def index
    if admin?
      @ecards = SentEcard.all
    else
      redirect_to "/login_form?previous_page=sent_ecards"
    end
  end
  
  def new
    
  end
  
  def json_list
    ecards = SentEcard.find :all
    render :json => ecards
  end
  
  def edit
    if admin?
      @ecard = SentEcard.find(params[:id])
    else
      redirect_to "/login_form"
    end
  end
  
  def update
    if admin?
      #e = SentEcard.find(params[:id])
      #puts "Updating all fields: Title: #{params[:title]}" 
      #e.update_attributes(  )
      redirect_to :action => 'index'
    else
      redirect_to "/login_form"
    end
  end
  
  def show
    @ecard = SentEcard.find(params[:id])
  end 
  
  def create
    if admin?
      #create new SentEcard
      redirect_to :action => "index"
    else
      redirect_to "/login_form"
    end
  end
  
  def destroy
    if admin?
    #should implement destroy (ignacio)
    
    begin
      e = SentEcard.find_by_id params[:id]
    rescue
      p "Unable to find ecard"
      raise
    end
    
    SentEcard.delete(params[:id])
    
    redirect_to :action => "index"
    else
      redirect_to "/login_form"
    end
  end
end
  