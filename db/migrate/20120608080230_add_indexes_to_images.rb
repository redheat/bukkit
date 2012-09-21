class AddIndexesToImages < ActiveRecord::Migration
  def up
    add_index('images', :url, { :name => 'images_url_index', :unique => true })
  end

  def down
    remove_index('images', :name => 'images_url_index')
  end
end
