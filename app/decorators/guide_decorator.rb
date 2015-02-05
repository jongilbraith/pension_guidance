class GuideDecorator < Draper::Decorator
  delegate :id, :slug

  def url
    "/#{slug}"
  end

  def title
    @title ||= case source_type
               when '.md'
                 source_document.headers.find { |header| header.level == 1 }.try(:text)
               else
                 source_document.css('h1').first.try(:text)
               end
  end

  def description
    source.front_matter['description']
  end

  def content
    @content ||= case source_type
                 when '.md'
                   source_document.to_sanitized_html.html_safe
                 else
                   source_content.html_safe
                 end
  end

  private

  def source
    @source ||= FrontMatterParser.new(File.read(object.source))
  end

  def source_type
    @source_type ||= File.extname(object.source)
  end

  def source_content
    @source_content ||= source.content
  end

  def source_document
    @source_document ||= case source_type
                         when '.md'
                           Govspeak::Document.new(source_content)
                         when '.html'
                           Nokogiri::HTML(source_content)
                         end
  end
end
