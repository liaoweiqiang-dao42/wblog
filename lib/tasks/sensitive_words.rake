namespace :sensitive_words do
  desc "Load sensitive words seed data"
  task seed: :environment do
    # 敏感词种子数据
    puts "开始添加敏感词种子数据..."

    # 严重敏感词 (severity: 3) - 完全禁止发布
    severe_words = [
      { word: "暴力", description: "暴力相关内容", severity: 3 },
      { word: "恐怖", description: "恐怖主义相关", severity: 3 },
      { word: "色情", description: "色情内容", severity: 3 },
      { word: "赌博", description: "赌博相关", severity: 3 },
      { word: "毒品", description: "毒品相关", severity: 3 },
      { word: "诈骗", description: "诈骗相关", severity: 3 },
      { word: "邪教", description: "邪教相关", severity: 3 },
      { word: "反动", description: "反动言论", severity: 3 },
      { word: "极端", description: "极端主义", severity: 3 },
      { word: "仇恨", description: "仇恨言论", severity: 3 }
    ]

    # 中等敏感词 (severity: 2) - 阻止发布，需要修改
    moderate_words = [
      { word: "垃圾", description: "垃圾信息", severity: 2 },
      { word: "骗子", description: "骗子相关", severity: 2 },
      { word: "废物", description: "恶意辱骂", severity: 2 },
      { word: "蠢货", description: "恶意辱骂", severity: 2 },
      { word: "白痴", description: "恶意辱骂", severity: 2 },
      { word: "滚蛋", description: "恶意辱骂", severity: 2 },
      { word: "死掉", description: "恶意诅咒", severity: 2 },
      { word: "去死", description: "恶意诅咒", severity: 2 },
      { word: "该死", description: "恶意诅咒", severity: 2 },
      { word: "仇杀", description: "暴力威胁", severity: 2 }
    ]

    # 轻微敏感词 (severity: 1) - 允许发布，仅记录日志
    mild_words = [
      { word: "愚蠢", description: "轻微不当用词", severity: 1 },
      { word: "讨厌", description: "负面情绪", severity: 1 },
      { word: "恼火", description: "负面情绪", severity: 1 },
      { word: "生气", description: "负面情绪", severity: 1 },
      { word: "烦人", description: "负面情绪", severity: 1 },
      { word: "无聊", description: "负面情绪", severity: 1 },
      { word: "糟糕", description: "负面评价", severity: 1 },
      { word: "失败", description: "负面评价", severity: 1 },
      { word: "差劲", description: "负面评价", severity: 1 },
      { word: "烂透", description: "负面评价", severity: 1 }
    ]

    # 批量创建敏感词
    all_words = severe_words + moderate_words + mild_words

    created_count = 0
    all_words.each do |word_data|
      sensitive_word = SensitiveWord.find_or_initialize_by(word: word_data[:word].downcase)
      
      if sensitive_word.new_record?
        sensitive_word.assign_attributes(
          description: word_data[:description],
          severity: word_data[:severity],
          enabled: true
        )
        
        if sensitive_word.save
          created_count += 1
          puts "✓ 添加敏感词: #{word_data[:word]} (#{sensitive_word.severity_text})"
        else
          puts "✗ 添加失败: #{word_data[:word]} - #{sensitive_word.errors.full_messages.join(', ')}"
        end
      else
        puts "- 跳过已存在的敏感词: #{word_data[:word]}"
      end
    end

    puts "\n敏感词种子数据添加完成!"
    puts "总共创建了 #{created_count} 个新敏感词"
    puts "严重敏感词: #{SensitiveWord.by_severity(3).count} 个"
    puts "中等敏感词: #{SensitiveWord.by_severity(2).count} 个"
    puts "轻微敏感词: #{SensitiveWord.by_severity(1).count} 个"
    puts "启用状态: #{SensitiveWord.enabled.count} 个"
  end
end