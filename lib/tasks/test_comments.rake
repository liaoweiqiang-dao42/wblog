namespace :test_comments do
  desc "Create test comments to verify sensitive word filtering"
  task create: :environment do
    puts "开始创建测试评论..."
    
    # 获取第一篇文章用于测试
    post = Post.first
    unless post
      puts "❌ 没有找到文章，请先创建一些文章"
      return
    end
    
    puts "在文章《#{post.title}》上创建测试评论..."

    # 测试评论数据
    test_comments = [
      {
        name: "正常用户",
        email: "normal@example.com",
        content: "这是一篇很好的文章，感谢作者的分享！学到了很多知识。",
        expected: :success
      },
      {
        name: "轻微敏感词用户", 
        email: "mild@example.com",
        content: "文章有点无聊，但整体还是不错的，虽然有些糟糕的地方需要改进。",
        expected: :success
      },
      {
        name: "中等敏感词用户",
        email: "moderate@example.com", 
        content: "这个作者简直是蠢货，写的内容就是垃圾，白痴才会看这种废物文章。",
        expected: :blocked
      },
      {
        name: "严重敏感词用户",
        email: "severe@example.com",
        content: "这种暴力和色情的内容应该被禁止，涉及赌博和毒品的话题不合适。",
        expected: :blocked
      },
      {
        name: "敏感用户名测试",
        email: "bad@example.com",
        content: "正常的评论内容",
        expected: :success  # 名字中没有严重敏感词
      },
      {
        name: "暴力用户",
        email: "violent@example.com", 
        content: "正常的评论内容",
        expected: :blocked  # 名字包含严重敏感词
      }
    ]

    success_count = 0
    blocked_count = 0
    unexpected_count = 0

    test_comments.each_with_index do |comment_data, index|
      comment = Comment.new(
        post: post,
        name: comment_data[:name],
        email: comment_data[:email],
        content: comment_data[:content]
      )
      
      saved = comment.save
      
      case comment_data[:expected]
      when :success
        if saved
          success_count += 1
          puts "✅ 测试 #{index + 1}: #{comment_data[:name]} - 评论成功发布（符合预期）"
        else
          unexpected_count += 1
          puts "❌ 测试 #{index + 1}: #{comment_data[:name]} - 评论被意外阻止"
          puts "   错误: #{comment.errors.full_messages.join(', ')}"
        end
      when :blocked
        if saved
          unexpected_count += 1
          puts "❌ 测试 #{index + 1}: #{comment_data[:name]} - 评论意外通过验证"
        else
          blocked_count += 1
          puts "✅ 测试 #{index + 1}: #{comment_data[:name]} - 评论被正确阻止（符合预期）"
          puts "   原因: #{comment.errors.full_messages.join(', ')}"
        end
      end
    end

    puts "\n=== 测试结果汇总 ==="
    puts "成功发布: #{success_count} 条"
    puts "正确阻止: #{blocked_count} 条"
    puts "意外结果: #{unexpected_count} 条"
    puts "总评论数: #{Comment.count} 条"
    
    if unexpected_count == 0
      puts "\n🎉 所有测试都符合预期！敏感词过滤功能正常工作。"
    else
      puts "\n⚠️  有 #{unexpected_count} 个测试结果不符合预期，请检查敏感词配置。"
    end
  end

  desc "Clean test comments"
  task clean: :environment do
    puts "清理测试评论..."
    
    test_emails = [
      "normal@example.com",
      "mild@example.com", 
      "moderate@example.com",
      "severe@example.com",
      "bad@example.com",
      "violent@example.com"
    ]
    
    deleted_count = 0
    test_emails.each do |email|
      comments = Comment.where(email: email)
      comments.each do |comment|
        comment.destroy
        deleted_count += 1
        puts "✓ 删除评论: #{comment.name} - #{comment.email}"
      end
    end
    
    puts "\n清理完成，删除了 #{deleted_count} 条测试评论"
  end

  desc "Show comment statistics"
  task stats: :environment do
    puts "=== 评论统计 ==="
    puts "总评论数: #{Comment.count}"
    puts "最近评论:"
    Comment.order(created_at: :desc).limit(5).each do |comment|
      puts "  • #{comment.name}: #{comment.content[0..50]}#{'...' if comment.content.length > 50}"
    end
  end
end