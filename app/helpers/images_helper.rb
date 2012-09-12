module ImagesHelper
  def thumbnail_size(image)
  	return :width => image.thumbnail_width, :height => image.thumbnail_height

  	if image.width >= image.height
  		h = (144 / image.width.to_f) * image.height
  		w = 144
  	else
  		h = 144
  		w = (144 / image.height.to_f) * image.width
  	end

  	return :width => w, :height => h
  end
end
