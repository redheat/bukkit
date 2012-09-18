class Image < ActiveRecord::Base
  validates :name, :presence => true
  validates :url, :presence => true
  validates_uniqueness_of :url
  
  self.per_page = 40
  
  def path
    Rails.root.join('public', 'downloads', name)
  end

  def exists?
    File.exists? path
  end
  
  def download(url)
    File.open(path, 'w:ASCII-8BIT') do |f|
      uri = URI.parse "#{url}#{self.name}".gsub(/\s/, '%20')
      Net::HTTP.start(uri.host, uri.port) do |http|
        http.request_get(uri.path) do |res|
          res.read_body { |seg|
            f << seg
            sleep 0.005
          }
        end
      end
    end

    self.save
  end

  def update_sizes
    if exists?
      # begin
        img = MiniMagick::Image::open(path)
        width = img[:width]
        height = img[:height]

        if img[:width] >= img[:height]
          thumbnail_width = 144
          thumbnail_height = (144 / img[:width].to_f) * img[:height]
        else
          ratio = 144 / img[:height]
          thumbnail_width = (144 / img[:height].to_f) * img[:width]
          thumbnail_height = 144
        end

        return {
          :width => width,
          :height => height,
          :thumbnail_width => thumbnail_width.round,
          :thumbnail_height => thumbnail_height.round
        }
      # rescue
      #   puts "Error #{$1}"
      # end
    
    end

    nil
  end

  def update_sizes!
    sizes = update_sizes()
    update_attributes!(sizes) if !sizes.nil?
  end

  def rename_file(old_name)
    if self.url == '/downloads/' + old_name
      self.url = '/downloads/' + self.name

      File.rename(
        Rails.root.join('public', 'downloads', old_name),
        Rails.root.join('public', 'downloads', self.name)
      )
    end
  end

  def rename_file!(old_name)
    self.rename_file(old_name)
    self.save
  end

  def self.from_upload(uploaded_io)
    image = Image.new
    
    @image.name = uploaded_io.original_filename
    @image.url = '/downloads/' + uploaded_io.original_filename
    @image.date_modified = Time.now
    
    File.open(Rails.root.join('public', 'downloads', uploaded_io.original_filename), 'w:ASCII-8BIT') do |file|
      file.write(uploaded_io.read)
    end

    image
  end
end
