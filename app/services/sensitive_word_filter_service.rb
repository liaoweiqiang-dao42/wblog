class SensitiveWordFilterService
  attr_reader :content, :detected_words, :filtered_content

  def initialize(content)
    @content = content.to_s
    @detected_words = []
    @filtered_content = content.to_s
    @sensitive_words_cache = nil
  end

  # 检测敏感词
  def detect
    return self if @content.blank?
    
    @detected_words = []
    sensitive_words.each do |sensitive_word|
      if content_contains_word?(sensitive_word.word)
        @detected_words << {
          word: sensitive_word.word,
          severity: sensitive_word.severity,
          description: sensitive_word.description
        }
      end
    end
    
    self
  end

  # 过滤敏感词（替换为*）
  def filter
    detect if @detected_words.empty?
    
    @filtered_content = @content.dup
    @detected_words.each do |word_data|
      word = word_data[:word]
      replacement = '*' * word.length
      @filtered_content = @filtered_content.gsub(/#{Regexp.escape(word)}/i, replacement)
    end
    
    self
  end

  # 检查内容是否包含敏感词
  def contains_sensitive_words?
    detect if @detected_words.empty?
    @detected_words.any?
  end

  # 获取最高严重等级
  def max_severity
    return 0 unless contains_sensitive_words?
    @detected_words.map { |w| w[:severity] }.max
  end

  # 检查是否包含严重敏感词
  def contains_severe_words?
    max_severity >= SensitiveWord::SEVERITY_LEVELS[:severe]
  end

  # 检查是否包含中等敏感词
  def contains_moderate_words?
    max_severity >= SensitiveWord::SEVERITY_LEVELS[:moderate]
  end

  # 获取检测结果摘要
  def detection_summary
    return "内容安全" unless contains_sensitive_words?
    
    severity_counts = @detected_words.group_by { |w| w[:severity] }
                                    .transform_values(&:count)
    
    summary = []
    summary << "发现#{severity_counts[3] || 0}个严重敏感词" if severity_counts[3]
    summary << "发现#{severity_counts[2] || 0}个中等敏感词" if severity_counts[2]
    summary << "发现#{severity_counts[1] || 0}个轻微敏感词" if severity_counts[1]
    
    summary.join(", ")
  end

  # 类方法：快速检测
  def self.quick_detect(content)
    new(content).detect
  end

  # 类方法：快速过滤
  def self.quick_filter(content)
    new(content).filter
  end

  # 类方法：检查是否可以发布
  def self.publishable?(content, max_allowed_severity: 2)
    service = new(content).detect
    service.max_severity <= max_allowed_severity
  end

  private

  # 获取启用的敏感词缓存
  def sensitive_words
    @sensitive_words_cache ||= SensitiveWord.enabled.to_a
  end

  # 检查内容是否包含特定敏感词
  def content_contains_word?(word)
    # 不区分大小写的匹配
    @content.downcase.include?(word.downcase)
  end

  # 清除缓存（用于测试或更新敏感词后）
  def self.clear_cache
    @sensitive_words_cache = nil
  end
end