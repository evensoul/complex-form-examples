class Task < ActiveRecord::Base
  belongs_to :project
  has_many  :colors, :dependent => :destroy
  validates_presence_of :name
  
  accepts_nested_attributes_for :colors, :allow_destroy => true, :reject_if => proc { |a| a['name'].blank? }
  
  attr_accessor :raise_exception
  
  after_save :raise_exception_if_needed
  def raise_exception_if_needed
    if @raise_exception.to_i == 1
      raise 'Oh noes!'
    end
  end
end
