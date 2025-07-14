class CommentsController < ApplicationController
  layout false

  def create
    cookies[:name] = comment_params[:name]
    cookies[:email] = comment_params[:email]

    @post = Post.find( params[:blog_id] )
    @comments = @post.comments.order(created_at: :desc)

    @comment = @post.comments.build(comment_params)
    if @comment.save
      flash.now[:notice] = '评论发表成功'
      # 重新加载评论列表
      @comments = @post.comments.order(created_at: :desc)
      # 重置评论表单
      @comment = Comment.new
    else
      # 显示验证错误（包括敏感词过滤错误）
      flash.now[:error] = @comment.errors.full_messages.join(', ')
    end
  end

  def refresh
    @post = Post.find(params[:blog_id])
    @comments = @post.comments.order(created_at: :desc)
  end

  private
  def comment_params
    params.require(:comment).permit(:content, :name, :email)
  end
end
