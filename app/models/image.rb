# This is the main Image class
# it does some stuff

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
    File.open(path, 'w:ASCII-8BIT') do |file|
      uri = URI.parse "#{url}#{self.name}".gsub(/\s/, '%20')
      Net::HTTP.start(uri.host, uri.port) do |http|
        http.request_get(uri.path) do |res|
          res.read_body { |seg|
            file << seg
            sleep 0.005
          }
        end
      end
    end

    self.save
  end

  def update_image(image)
    old_name = self.name
    self.update_attributes(image)
    self.rename_file(old_name)
    self.save
  end

  def update_sizes
    if exists?
      # begin
        img = MiniMagick::Image::open(path)
        width = img[:width]
        height = img[:height]

        if width >= height
          thumbnail_width = 144
          thumbnail_height = (144 / width.to_f) * height
        else
          ratio = 144 / height
          thumbnail_width = (144 / height.to_f) * width
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
    end

    File.rename(
      Rails.root.join('public', 'downloads', old_name),
      path
    )
  end

  def rename_file!(old_name)
    self.rename_file(old_name)
    self.save
  end

  def self.from_upload(uploaded_io)
    image = Image.new
    name = uploaded_io.original_filename

    image.name = name
    image.url = '/downloads/' + name
    image.date_modified = Time.now

    File.open(Rails.root.join('public', 'downloads', name), 'w:ASCII-8BIT') do |file|
      file.write(uploaded_io.read)
    end

    image
  end
end
