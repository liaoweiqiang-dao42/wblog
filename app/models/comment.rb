class Comment < ApplicationRecord
  belongs_to :post

  validates :name, presence: true
  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :content, presence: true, length: { minimum: 4 }
  validate :check_sensitive_words

  def reply_emails
    Comment.where(post_id: self.post_id).collect(&:email).uniq - [ self.email ] - Subscribe.unsubscribe_list - [ ENV['ADMIN_USER'] ]
  end

  private

  def check_sensitive_words
    # 检查评论内容
    content_filter = SensitiveWordFilterService.new(content)
    content_filter.detect
    
    if content_filter.contains_severe_words?
      errors.add(:content, "包含严重敏感词，无法发布")
    elsif content_filter.contains_moderate_words?
      errors.add(:content, "包含中等敏感词，请修改后重试")
    end
    
    # 检查姓名（轻微检查）
    name_filter = SensitiveWordFilterService.new(name)
    name_filter.detect
    
    if name_filter.contains_severe_words?
      errors.add(:name, "姓名包含不合适内容")
    end
    
    # 记录日志
    if content_filter.contains_sensitive_words? || name_filter.contains_sensitive_words?
      Rails.logger.warn "Comment sensitive word detection: Name[#{name_filter.detection_summary}], Content[#{content_filter.detection_summary}]"
    end
  end
end
