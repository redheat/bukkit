class Scraper
  def self.scrape(url)
    if url == 'http://bukk.it/'
      self.scrape_table url
    else
      self.scrape_fixed_width url
    end
  end
  
  def self.extract_name(name)
    name.to_s.split('/').last
  end
  
  def self.scrape_table(url = 'http://bukk.it/')
    agent = Mechanize.new
    page = agent.get url
    images = page.search '//tr[td[a[@href]]]'

    images.each do |row|
      name = self.extract_name(row.search('td/a[@href]/@href'))
      modified = DateTime.parse row.search('td[@align=right]/text()').to_s

      self.save_image(name, url, modified)
    end
  end
  
  def self.scrape_fixed_width(url)
    agent = Mechanize.new
    page = agent.get url
    section = page.search '//pre'

    images = section.first.to_html.split("\n")
    idx = images.index { |i| !i.nil? && i.strip.match(/^<hr>/) } + 1
    
    images.drop(idx).each do |i|
      if !i.nil?
        i.strip!
        begin
          row = Nokogiri::HTML::fragment "<td>#{i}</td>"
          name = self.extract_name(row.search('a[@href]/@href'))
          modified = DateTime.parse i[-30, 25].strip

          self.save_image(name, url, modified)
        rescue NoMethodError => e
          # assuming the date can’t be found
        end
      end
    end
  end
  
  def self.save_image(name, url, modified)
    if name.ends_with? '/'
      self.delay(:priority => 20).scrape_fixed_width("#{url}#{name}")
    else
      image = Image.new(:name => name, :url => "#{url}#{name}", :date_modified => modified)
      Image.download(image.name, url) unless Image.exists?(image.name)
      image.save
    end
  end
end
