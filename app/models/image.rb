class Image < ActiveRecord::Base
  validates :name, :presence => true
  validates :url, :presence => true
  validates_uniqueness_of :url
  
  def self.exists?(name)
    File.exists? "#{Rails.root}/public/downloads/#{name}"
  end
  
  def self.download(name, url)
    File.open("#{Rails.root}/public/downloads/#{name}", 'w') do |f|
      uri = URI.parse "#{url}#{name}"
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
