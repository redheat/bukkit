class AddOrderedIndexToImages < ActiveRecord::Migration
  def up
    add_index('images', :date_modified, { :name => 'users_modified_order_index', :order => { :date_modified => :desc }})
  end
  
  def down
    remove_index('images', :name => 'users_modified_order_index')
  end
end
