class SensitiveWord < ApplicationRecord
  validates :word, presence: true, uniqueness: { case_sensitive: false }
  validates :severity, inclusion: { in: [1, 2, 3] }
  
  # 作用域
  scope :enabled, -> { where(enabled: true) }
  scope :by_severity, ->(level) { where(severity: level) }
  
  # 严重程度常量
  SEVERITY_LEVELS = {
    mild: 1,      # 轻微
    moderate: 2,  # 中等
    severe: 3     # 严重
  }.freeze
  
  def severity_text
    case severity
    when 1
      '轻微'
    when 2
      '中等'
    when 3
      '严重'
    else
      '未知'
    end
  end
  
  # 批量导入敏感词
  def self.import_words(words_array)
    words_array.each do |word_data|
      word = word_data.is_a?(Hash) ? word_data[:word] : word_data
      description = word_data.is_a?(Hash) ? word_data[:description] : nil
      severity = word_data.is_a?(Hash) ? word_data[:severity] : 1
      
      find_or_create_by(word: word.to_s.strip.downcase) do |sw|
        sw.description = description
        sw.severity = severity
        sw.enabled = true
      end
    end
  end
end
