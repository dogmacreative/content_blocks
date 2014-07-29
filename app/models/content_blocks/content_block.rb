module ContentBlocks
	class ContentBlock < ActiveRecord::Base

	  TYPES = [ 'text', 'html', 'title', 'link', 'image', 'simple', 'file', 'read_more' ]

	end
end