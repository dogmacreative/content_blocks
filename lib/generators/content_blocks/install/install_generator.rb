require 'rails/generators'

module ContentBlocks
  module Generators
    class InstallGenerator < Rails::Generators::Base

      desc "Install ContentBlocks"

      def self.source_root
        @source_root ||= File.expand_path('../templates', __FILE__)
      end

      def create_migrations
        rake "content_blocks:install:migrations"
      end
    end
  end
end