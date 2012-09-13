module ImagesHelper
  def thumbnail_size(image)
    image.delay.update_sizes!(image.name) if image.width.nil? or image.height.nil?
    return :width => image.thumbnail_width, :height => image.thumbnail_height
  end
end
