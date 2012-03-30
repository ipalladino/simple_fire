require 'net/ftp.rb'

class EcardsController < ApplicationController
  
  @@FTP_SERVER = "ftp.simplecustomsolutions.com"
  @@SWF_DIR = "/simplecustomsolutions.com/artiphany_assets/ecard_swfs/"
  @@IMAGES_DIR = "/simplecustomsolutions.com/artiphany_assets/ecard_images/"
  @@VIDEOS_DIR = "/simplecustomsolutions.com/artiphany_assets/ecard_videos/"
  @@ARTIPHANY_ASSETS = "/simplecustomsolutions.com/artiphany_assets/"
  #there has to be a directory with the name ecard_swfs
  #there has to be a directory with the name ecard_images
  #there has to be a directory with the name ecard_videos
  
  def index
    @ecards = Ecard.all
  end
  
  def new
    
  end
  
  def json_list
    ecards = Ecard.find :all
    render :json => ecards
  end
  
  def edit
    @ecard = Ecard.find(params[:id])
  end
  
  def update
    e = Ecard.find(params[:id])
    e.update_attributes(
      :title => params[:title],
      :description => params[:description],
      :tags => params[:tags],
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
    swf_file = params[:swf_file]
    image_file = params[:image_file]
    video_file = params[:video_file]
    
    timestamp = Time.now.utc.iso8601.gsub(/\W/, '')
     
    begin
      p "Connect to " + @@FTP_SERVER
      ftp = Net::FTP.new(@@FTP_SERVER)
      ftp.passive = true
    rescue SocketError
      p "Unable to connect to " + @@FTP_SERVER
      raise
    else
      p "Connected Successfully!"
    end
      
    begin
      p "Attemping to login to ftp server"
      ftp.login(user = "ipalladino", passwd = "ip8801ip")
      ftp.chdir(@@SWF_DIR)
    rescue 
      p "Failed to log in to the server"
      raise
    else
      p "Log in succesfull to server"
    end
    
    p "Listing files:"
    ftp.list.each {|file| printf file+"\n"}
    
    begin
      p "Attemping to copy " + File.basename(swf_file.original_filename)
      p "swf_file.original_filename: "+ swf_file.original_filename
      #ftp.putbinaryfile(swf_file.read, "somefile.swf")
      
      unless swf_file.blank?
        ftp.chdir(@@SWF_DIR)
        ftp.storbinary("STOR " + timestamp + "_" + swf_file.original_filename, StringIO.new(swf_file.read), Net::FTP::DEFAULT_BLOCKSIZE)
        swf_string = timestamp + "_" + File.basename(swf_file.original_filename)
      else
        swf_string = ""
      end
      
      unless image_file.blank?
        ftp.chdir(@@IMAGES_DIR)
        ftp.storbinary("STOR "+timestamp+"_"+image_file.original_filename, StringIO.new(image_file.read), Net::FTP::DEFAULT_BLOCKSIZE)
        image_string = timestamp + "_" + File.basename(image_file.original_filename)
      else
        image_string = ""
      end
      
      unless video_file.blank?
        ftp.chdir(@@VIDEOS_DIR)
        ftp.storbinary("STOR "+timestamp+"_"+ video_file.original_filename, StringIO.new(video_file.read), Net::FTP::DEFAULT_BLOCKSIZE)
        video_string = timestamp + "_" + File.basename(video_file.original_filename)
      else
        video_string = ""
      end
      
      ftp.quit
    rescue
      p "Unable to copy binary file"
      raise
    else
      p "File successfully uploaded!"
    end
    
    e = Ecard.create(
      :title => params[:title],
      :description => params[:description],
      :tags => params[:tags],
      :price => params[:price],
      :image => image_string,
      :filename => swf_string,
      :video_file => video_string
    )
    redirect_to :action => "index"
  end
  
  def destroy
    #should implement destroy (ignacio)
    
    begin
      e = Ecard.find_by_id params[:id]
    rescue
      p "Unable to find ecard"
      raise
    end
    
    Ecard.delete(params[:id])
    
    begin
      p "Connect to " + @@FTP_SERVER
      ftp = Net::FTP.new(@@FTP_SERVER)
      ftp.passive = true
    rescue SocketError
      p "Unable to connect to " + @@FTP_SERVER
      raise
    else
      p "Connected Successfully!"
    end
    
    begin
      p "Attemping to login to ftp server"
      ftp.login(user = "ipalladino", passwd = "ip8801ip")
      ftp.chdir(@@ARTIPHANY_ASSETS)
    rescue 
      p "Failed to log in to the server"
      raise
    else
      p "Log in succesfull to server"
    end
    
    begin
      p "Attemping to delete all three files swf:" + e.filename + ", image:" + e.image + ", video_file: "+ e.video_file
      #ftp.putbinaryfile(swf_file.read, "somefile.swf")
      unless e.filename.blank?
        ftp.delete("ecard_swfs/" + e.filename)
      end
      unless e.image.blank?
        ftp.delete("ecard_images/" + e.image)
      end
      unless e.video_file.blank?
        ftp.delete("ecard_videos/" + e.video_file)
      end
      ftp.quit
    rescue
      p "Unable to copy binary file"
      raise
    else
      p "Files successfully deleted!"
    end
    
    
    
    redirect_to :action => "index"
  end
end
