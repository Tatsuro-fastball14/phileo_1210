class Category < ActiveRecord
  # self.data = [
  #   {id: 1, name: '---' },     
  #   {id: 2, name: '沖縄'},
  #   {id: 3, name: '那覇市'},
  #   {id: 4, name: '浦添市'},
   
    
 
   has_many :place 
end
