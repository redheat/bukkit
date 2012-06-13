class Image < ActiveRecord::Base
  validates :name, :presence => true
  validates :url, :presence => true
  validates_uniqueness_of :url
  
  self.per_page = 40
  
  def self.exists?(name)
    File.exists? "#{Rails.root}/public/downloads/#{name}"
  end
  
  def self.download(name, url)
    File.open("#{Rails.root}/public/downloads/#{name}", 'w') do |f|
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
end
