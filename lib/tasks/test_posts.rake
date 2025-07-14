namespace :test_posts do
  desc "Create test posts to verify sensitive word filtering"
  task create: :environment do
    puts "开始创建测试文章..."

    # 测试文章数据
    test_posts = [
      {
        title: "正常的技术文章",
        content: "这是一篇关于Ruby on Rails开发的技术文章。Rails是一个优秀的Web开发框架，它遵循约定优于配置的原则，让开发变得更加高效。在这篇文章中，我将分享一些Rails开发的最佳实践。"
      },
      {
        title: "包含轻微敏感词的文章",
        content: "今天的工作真的很无聊，感觉有点糟糕。不过我还是会继续努力的，虽然有时候会生气，但我知道失败是成功之母。"
      },
      {
        title: "包含中等敏感词的标题 - 这是垃圾文章",
        content: "这是一篇普通的内容，没有问题。"
      },
      {
        title: "正常标题",
        content: "这个蠢货根本不懂技术，简直是废物一个。这种白痴还敢来教别人编程，真是该死的骗子。"
      },
      {
        title: "严重敏感词测试 - 暴力内容",
        content: "这是一篇测试文章。"
      },
      {
        title: "另一个正常标题",
        content: "我们反对一切形式的暴力和恐怖行为，这种色情和赌博的内容应该被禁止。毒品和诈骗害人不浅。"
      }
    ]

    created_count = 0
    failed_count = 0
    
    test_posts.each_with_index do |post_data, index|
      post = Post.new(
        title: post_data[:title],
        content: post_data[:content]
      )
      
      if post.save
        created_count += 1
        puts "✓ 成功创建文章 #{index + 1}: #{post.title}"
      else
        failed_count += 1
        puts "✗ 创建失败 #{index + 1}: #{post_data[:title]}"
        puts "  错误信息: #{post.errors.full_messages.join(', ')}"
      end
    end

    puts "\n测试文章创建完成!"
    puts "成功创建: #{created_count} 篇"
    puts "创建失败: #{failed_count} 篇"
    puts "总文章数: #{Post.count} 篇"
  end

  desc "Remove test posts"
  task clean: :environment do
    puts "清理测试文章..."
    
    test_titles = [
      "正常的技术文章",
      "包含轻微敏感词的文章", 
      "包含中等敏感词的标题 - 这是垃圾文章",
      "正常标题",
      "严重敏感词测试 - 暴力内容",
      "另一个正常标题"
    ]
    
    deleted_count = 0
    test_titles.each do |title|
      posts = Post.where("title LIKE ?", "%#{title}%")
      posts.each do |post|
        post.destroy
        deleted_count += 1
        puts "✓ 删除文章: #{post.title}"
      end
    end
    
    puts "\n清理完成，删除了 #{deleted_count} 篇测试文章"
  end
end