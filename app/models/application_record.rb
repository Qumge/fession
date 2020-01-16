class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def view_errors
  	if self.errors 
  		message = self.errors.messages.first
  		message_name = message[0]
  		maessage_content = message[1][0]
  		s = I18n.t "activerecord.attributes.#{self.class.table_name}.#{message_name}"
  		if s.include? 'translation missing'
  			"#{maessage_content}"
  		else
  			"#{s}: #{maessage_content}"
  		end
  	end
  end

end
