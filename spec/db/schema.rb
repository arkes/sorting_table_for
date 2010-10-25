ActiveRecord::Schema.define(:version => 0) do

  create_table :users, :force => true do |t|
    
    t.string    :username
    t.string    :firstname
    t.string    :lastname
    
    t.integer   :position
    t.integer   :salary
    t.integer   :price
    
    t.boolean   :active
    
    t.datetime  :created_at
    t.datetime  :updated_at
    
  end
  
end
