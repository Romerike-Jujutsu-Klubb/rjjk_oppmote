require 'record'

class Group < Record
  attr_reader :members
  
  def initialize(*args)
    @members = []
    super
  end

end