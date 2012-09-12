class AddDimensionsToImages < ActiveRecord::Migration
  class Image < ActiveRecord::Base
  	def update_dimensions!(name)
	    file = "#{Rails.root}/public/downloads/#{name}"
	    width = 0
	    height = 0
	    thumbnail_width = 0
	    thumbnail_height = 0

	    if File.exists?(file)
	    	begin
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
		  rescue
		  	puts "Error #{$1}"
		  end
	    end

	    self.update_attributes!(
	    	:width => width,
	    	:height => height,
	    	:thumbnail_width => thumbnail_width.round,
	    	:thumbnail_height => thumbnail_height.round
	    )
	  end
  end

  def up
  	add_column :images, :width, :integer
  	add_column :images, :height, :integer
  	add_column :images, :thumbnail_width, :integer
  	add_column :images, :thumbnail_height, :integer

  	Image.all.each do |image|
  		image.update_dimensions!(image.name)
  	end
  end

  def down
  	remove_column :images, :width
  	remove_column :images, :height
  	remove_column :images, :thumbnail_width
  	remove_column :images, :thumbnail_height
  end
end
