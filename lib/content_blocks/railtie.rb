require 'content_blocks/content_blocks_helpers'
module ContentBlocks
  class Railtie < Rails::Railtie
    initializer "content_blocks.content_blocks_helpers" do
      ActionView::Base.send :include, ContentBlocksHelpers
    end
  end
end