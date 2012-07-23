class ImagesController < ApplicationController
  # GET /images
  # GET /images.json
  def index
    if params[:page] == ''
      params[:page] = 1
    end
    
    @images = Image.where('name LIKE ?', "%#{params[:search]}%").paginate(:page => params[:page]).order('date_modified DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @images }
    end
  end

  # GET /images/1
  # GET /images/1.json
  def show
    @image = Image.find(params[:id])
    
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
    @image = Image.find(params[:id])
  end

  # POST /images
  # POST /images.json
  def create
    @image = Image.new
    uploaded_io = params[:file]
    
    @image.name = uploaded_io.original_filename
    @image.url = '/downloads/' + uploaded_io.original_filename
    @image.date_modified = Time.now
    
    File.open(Rails.root.join('public', 'downloads', uploaded_io.original_filename), 'w:ASCII-8BIT') do |file|
      file.write(uploaded_io.read)
    end

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, :notice => 'Image was successfully created.' }
        format.json { render :json => @image, :status => :created, :location => @image }
      else
        format.html { render :action => "new" }
        format.json { render :json => @image.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /images/1
  # PUT /images/1.json
  def update
    @image = Image.find(params[:id])
    old_name = @image.name

    respond_to do |format|
      if @image.update_attributes(params[:image])
        format.html { redirect_to @image, :notice => 'Image was successfully updated.' }
        format.json { head :ok }
        
        if @image.url == '/downloads/' + old_name
          @image.url = '/downloads/' + @image.name
          @image.save
        end
        
        File.rename(
          Rails.root.join('public', 'downloads', old_name),
          Rails.root.join('public', 'downloads', @image.name)
        )
      else
        format.html { render :action => "edit" }
        format.json { render :json => @image.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image = Image.find(params[:id])
    @image.destroy

    respond_to do |format|
      format.html { redirect_to images_url }
      format.json { head :ok }
    end
  end
end
