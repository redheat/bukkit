class ImageObserver < ActiveRecord::Observer
  def after_save(image)
    image.delay.update_sizes! if image.width.nil? or image.height.nil?
  end
end