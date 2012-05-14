class Scraper
  def self.scrape(url = 'http://bukk.it/')
    agent = Mechanize.new
    page = agent.get url
    images = page.search '//tr[td[a[@href]]]'

    images.each do |i|
      self.delay.queue(i.to_html, url)
    end
  end
  
  def self.queue(row, url)
    row = Nokogiri::HTML::fragment row
    name = row.search('td/a[@href]/text()').to_s
    modified = DateTime.parse row.search('td[@align=right]/text()').to_s
    
    image = Image.new(:name => name, :url => "#{url}#{name}", :date_modified => modified)
    Image.delay(:priority => 10).download(image.name, url) unless Image.exists?(image.name)
    image.save
  end
end
