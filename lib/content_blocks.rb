require "content_blocks/version"
require "content_blocks/railtie" if defined?(Rails)

module ContentBlocks
  class Engine < ::Rails::Engine
  end
end
