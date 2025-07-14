require 'markdown'
class Post < ActiveRecord::Base
  has_many :comments
  has_and_belongs_to_many :labels

  has_many :likes

  validates :title, :presence=>true, :uniqueness=> true
  validates :content, :presence=>true, :length => { :minimum=> 3 }
  validate :check_sensitive_words

  def content_html
    self.class.render_html(self.content)
  end

  def self.render_html(content)
    rd = CodeHTML.new
    md = Redcarpet::Markdown.new(rd, autolink: true, fenced_code_blocks: true)
    md.render(content)
  end

  def visited
    self.visited_count += 1
    self.save
    self.visited_count
  end

  # truncate content for home page display
  def sub_content
    HTML_Truncator.truncate(content_html, 300, length_in_chars: true)
  end

  # truncate content for meta description display
  def meta_content
    html = HTML_Truncator.truncate(content_html, 100, :length_in_chars => true, ellipsis: '')
    # Easily get text for Nokogiri
    html = '<div>' + html + '</div>'
    Nokogiri.parse(html).text()
  end

  def labels_content( need_blank=false )
    content = self.labels.collect { |label| label.name }.join(", ")
    content = I18n.t('none') if content.blank? and !need_blank
    content
  end

  def liked_count
    self.likes.size
  end

  def liked_by?(like_id)
    !! self.likes.where(id: like_id).first
  end

  private

  def check_sensitive_words
    # 检查标题
    title_filter = SensitiveWordFilterService.new(title)
    title_filter.detect
    
    if title_filter.contains_severe_words?
      errors.add(:title, "包含严重敏感词，无法发布")
    elsif title_filter.contains_moderate_words?
      errors.add(:title, "包含中等敏感词，请修改后重试")
    end
    
    # 检查内容
    content_filter = SensitiveWordFilterService.new(content)
    content_filter.detect
    
    if content_filter.contains_severe_words?
      errors.add(:content, "包含严重敏感词，无法发布")
    elsif content_filter.contains_moderate_words?
      errors.add(:content, "包含中等敏感词，请修改后重试")
    end
    
    # 轻微敏感词只记录警告，不阻止发布
    if title_filter.contains_sensitive_words? || content_filter.contains_sensitive_words?
      Rails.logger.warn "Post sensitive word detection: Title[#{title_filter.detection_summary}], Content[#{content_filter.detection_summary}]"
    end
  end
end
