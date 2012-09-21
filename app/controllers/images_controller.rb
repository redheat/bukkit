class ImagesController < ApplicationController
  before_filter :find_image, :only => [:show, :edit, :update, :destroy]

  # GET /images
  # GET /images.json
  def index
    page = params[:page] || 1

    @images = Image.where('name LIKE ?', "%#{params[:search]}%").paginate(:page => page).order('date_modified DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @images }
    end
  end

  # GET /images/1
  # GET /images/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @image }
    end
  end

  # GET /images/new
  # GET /images/new.json
  def new
    @image = Image.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @image }
    end
  end

  # GET /images/1/edit
  def edit

  end

  # POST /images
  # POST /images.json
  def create
    @image = Image.from_upload(params[:file])

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, :notice => 'Image was successfully created.' }
        format.json { render :json => @image, :status => :created, :location => @image }
      else
        format.html { render 'new' }
        format.json { render :json => @image.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /images/1
  # PUT /images/1.json
  def update
    respond_to do |format|
      if @image.update_image(params[:image])
        format.html { redirect_to @image, :notice => 'Image was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render 'edit' }
        format.json { render :json => @image.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.destroy

    respond_to do |format|
      format.html { redirect_to images_url }
      format.json { head :ok }
    end
  end

  protected
    def find_image
      @image = Image.find(params[:id])
    end
end