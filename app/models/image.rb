class Image < ActiveRecord::Base
  validates :name, :presence => true
  validates :url, :presence => true
  validates_uniqueness_of :url
  
  self.per_page = 40
  
  def self.exists?(name)
    File.exists? "#{Rails.root}/public/downloads/#{name}"
  end
  
  def self.download(name, url)
    File.open("#{Rails.root}/public/downloads/#{name}", 'w:ASCII-8BIT') do |f|
      uri = URI.parse "#{url}#{name}".gsub(/\s/, '%20')
      Net::HTTP.start(uri.host, uri.port) do |http|
        http.request_get(uri.path) do |res|
          res.read_body { |seg|
            f << seg
            sleep 0.005
          }
        end
      end
    end
  end

  def update_sizes(name)
    file = "#{Rails.root}/public/downloads/#{name}"
    if File.exists?(file)
      # begin
        img = MiniMagick::Image::open(file)
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

  def update_sizes!(name)
    sizes = self.update_sizes(name)
    self.update_attributes!(sizes) if !sizes.nil?
  end
end
