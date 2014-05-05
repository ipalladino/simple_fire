require 'net/ftp.rb'

class EcardsController < ApplicationController
  # Security filter...
  before_filter :except => [:json_list, :show] do
    redirect_to "/login_form" unless admin?
  end

  # FTP session filters...
  before_filter :open_ftp, :only => [:create, :destroy, :update]
  after_filter :close_ftp, :only => [:create, :destroy, :update]

  def index
    @ecards = Ecard.all
  end
  
  def new
  end
  
  def json_list
    render :json => Ecard.all
  end
  
  def edit
    @ecard = Ecard.find(params[:id])
  end
  
  def update
    e = Ecard.find(params[:id])

    return redirect_to :action => 'index' unless e != nil

    swf_file = params[:swf_file]
    image_file = params[:image_file]
    video_file = params[:video_file]

    begin
      unless swf_file.blank?
        @ftp_session.chdir(Rails.application.config.ftp_swf_dir)
        @ftp_session.storbinary("STOR #{e.filename}.new", StringIO.new(swf_file.read), Net::FTP::DEFAULT_BLOCKSIZE)
        @ftp_session.rename(e.filename, "#{e.filename}.bak")
        @ftp_session.rename("#{e.filename}.new", e.filename)
        @ftp_session.delete("#{e.filename}.bak")
      end

      unless image_file.blank?
        @ftp_session.chdir(Rails.application.config.ftp_images_dir)
        @ftp_session.storbinary("STOR #{e.image}.new", StringIO.new(image_file.read), Net::FTP::DEFAULT_BLOCKSIZE)
        @ftp_session.rename(e.image, "#{e.image}.bak")
        @ftp_session.rename("#{e.image}.new", e.image)
        @ftp_session.delete("#{e.image}.bak")
      end

      unless video_file.blank?
        @ftp_session.chdir(Rails.application.config.ftp_videos_dir)
        @ftp_session.storbinary("STOR #{e.video_file}.new", StringIO.new(video_file.read), Net::FTP::DEFAULT_BLOCKSIZE)
        @ftp_session.rename(e.video_file, "#{e.video_file}.bak")
        @ftp_session.rename("#{e.video_file}.new", e.video_file)
        @ftp_session.delete("#{e.video_file}.bak")
      end
    rescue
      logger.error("Unable to copy binary file")
      raise
    else
      logger.debug("File successfully uploaded!")
    end

    e.update_attributes(
      :title => params[:title],
      :description => params[:description],
      :tags => params[:tags],
      :price => params[:price]
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
      unless swf_file.blank?
        @ftp_session.chdir(Rails.application.config.ftp_swf_dir)
        @ftp_session.storbinary("STOR " + timestamp + "_" + swf_file.original_filename, StringIO.new(swf_file.read), Net::FTP::DEFAULT_BLOCKSIZE)
        swf_string = timestamp + "_" + File.basename(swf_file.original_filename)
      else
        swf_string = ""
      end
      
      unless image_file.blank?
        @ftp_session.chdir(Rails.application.config.ftp_images_dir)
        @ftp_session.storbinary("STOR "+timestamp+"_"+image_file.original_filename, StringIO.new(image_file.read), Net::FTP::DEFAULT_BLOCKSIZE)
        image_string = timestamp + "_" + File.basename(image_file.original_filename)
      else
        image_string = ""
      end
      
      unless video_file.blank?
        @ftp_session.chdir(Rails.application.config.ftp_videos_dir)
        @ftp_session.storbinary("STOR "+timestamp+"_"+ video_file.original_filename, StringIO.new(video_file.read), Net::FTP::DEFAULT_BLOCKSIZE)
        video_string = timestamp + "_" + File.basename(video_file.original_filename)
      else
        video_string = ""
      end
    rescue
      logger.error("Unable to copy binary file")
      raise
    else
      logger.debug("File successfully uploaded!")
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
    begin
      e = Ecard.find_by_id params[:id]
    rescue
      logger.error("Unable to find ecard")
      raise
    end
    
    Ecard.delete(params[:id])

    begin
      @ftp_session.chdir(Rails.application.config.ftp_artiphany_assets_dir)

      logger.debug("Attemping to delete all three files swf:" + e.filename + ", image:" + e.image + ", video_file: "+ e.video_file)

      unless e.filename.blank?
        @ftp_session.delete("ecard_swfs/" + e.filename)
      end

      unless e.image.blank?
        @ftp_session.delete("ecard_images/" + e.image)
      end

      unless e.video_file.blank?
        @ftp_session.delete("ecard_videos/" + e.video_file)
      end
    rescue
      logger.error("Unable to delete binary file")
      raise
    else
      logger.debug("Files successfully deleted!")
    end
    
    redirect_to :action => "index"
  end

  private

  attr_accessor :ftp_session

  def open_ftp
    logger.debug('Opening FTP session!')

    @ftp_session = Net::FTP.new(Rails.application.config.ftp_server)
    @ftp_session.passive = true
    @ftp_session.login(Rails.application.config.ftp_user, Rails.application.config.ftp_password)
  rescue
    logger.error('Failed to log in to the server!')
    raise
  else
    logger.debug('FTP session is open!')
  end

  def close_ftp
    logger.debug('Closing FTP session!')

    if @ftp_session != nil and not @ftp_session.closed?
      @ftp_session.close
    end

    @ftp_session = nil
  rescue
    logger.error('Failed close FTP session!')
    raise
  else
    logger.debug('FTP session closed!')
  end
end
