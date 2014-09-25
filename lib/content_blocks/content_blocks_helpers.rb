module ContentBlocks
  module ContentBlocksHelpers

    def text_block(name, text, level = :shared)
      content_block name, text, nil, "text", level
    end

    def image_block(name, image_path, level = :shared)
      content_block( name, image_path, nil, "image", level ).image
    end

    def title_block(name, title, content, link = nil, level = :page, &block)
      page_id, section_id = define_level level

      content_block = ContentBlock
        .where( name: name, page_id: page_id, section_id: section_id )
        .first_or_create!(
          :title => title,
          :content => content,
          :link => link,
          :content_type => "title"
        )

        # version = content_block.versions.last.reify
        version = content_block

      capture version, &block
    end

    def content_block(name, content = nil, link = nil, type = "simple", level = :page, &block)
      page_id, section_id = define_level level

      image_or_content = type == "image" ? :image : :content

      content_block = ContentBlock
        .where( name: name, page_id: page_id, section_id: section_id )
        .first_or_create!(
          image_or_content => content,
          :link => link,
          :content_type => type
        )

      # version = content_block.versions.last.reify
      version = content_block

      if block_given?
        capture version, &block
      elsif version.content_type == "text"
        return version.content
      elsif version.content_type == "simple"
        return simple_format version.content
      elsif version.content_type == "html"
        return version.content.html_safe
      elsif version.content_type == "read_more"
        render partial: "shared/read_more", locals: { excerpt: version.link, content: version.content }
      else
        return version
      end 
    end

    def content_assoc(name, klass, id = nil, level = :page, &block)
      page_id, section_id = define_level level

      content_block = ContentBlock
        .where( name: name, page_id: page_id, section_id: section_id )
        .first_or_create!(
          content_type: klass.name,
          content_id: id
        )

        # version = content_block.versions.last.reify
        version = content_block

      if version.content_id.nil?
        content = nil
      else
        content_klass = version.content_type.constantize
        content = content_klass.where( id: version.content_id ).first
      end

      capture content, &block
    end

    def rich_image(image_path, new_style, old_style = nil)
      allowed_styles = Rich.image_styles.keys.map{ |s| s.downcase.to_s}
      new_style = new_style.downcase.to_s

      if allowed_styles.include?(new_style)
        if old_style.nil?
          allowed_styles.each do |style|      
            image_path = image_path.nil? ? nil : image_path.gsub("/#{style}/","/#{new_style}/")
          end
        else
          image_path = image_path.nil? ? nil : image_path.gsub("/#{old_style}/","/#{new_style}/")
        end
      end

      image_path
    end

    def nl2br(s)
      strip_tags(s).gsub(/(\r)?\n/, "<br />").html_safe
    end

    def highlight_lines(s)
      output = ""
      strip_tags(s).lines.map(&:chomp).each do |line|
        unless line.blank?
          output << "<br />" unless output.blank?
          output << "<i>#{line}</i>"
        end
      end
      output.html_safe
    end

    protected

    def define_level(level)
      page = nil
      section = nil

      case level
      when :page
        page = @page || Page.from_path( request.path, params[:controller] )
      when :section
        section = @section || Section.from_controller( params[:controller] )
      when :shared
        section = Section.where( name: "Shared" ).first
      end

      page_id = nil
      section_id = nil

      unless page.nil?
        page_id = page.id
      end

      unless section.nil?
        section_id = section.id
      end

      return page_id, section_id
    end
    
  end
end