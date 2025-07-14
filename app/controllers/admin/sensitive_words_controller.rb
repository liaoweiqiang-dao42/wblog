class Admin::SensitiveWordsController < Admin::BaseController
  before_action :set_sensitive_word, only: [:show, :edit, :update, :destroy, :toggle]

  def index
    @sensitive_words = SensitiveWord.order(:word).page(params[:page]).per(25)
    @sensitive_words = @sensitive_words.where("word ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    @sensitive_words = @sensitive_words.by_severity(params[:severity]) if params[:severity].present?
    @sensitive_words = @sensitive_words.where(enabled: params[:enabled] == 'true') if params[:enabled].present?
  end

  def show
  end

  def new
    @sensitive_word = SensitiveWord.new
  end

  def edit
  end

  def create
    @sensitive_word = SensitiveWord.new(sensitive_word_params)

    if @sensitive_word.save
      flash[:notice] = '敏感词添加成功'
      redirect_to admin_sensitive_words_path
    else
      flash.now[:error] = '添加失败'
      render :new, status: 422
    end
  end

  def update
    if @sensitive_word.update(sensitive_word_params)
      flash[:notice] = '敏感词更新成功'
      redirect_to admin_sensitive_words_path
    else
      flash[:error] = '更新失败'
      render :edit
    end
  end

  def destroy
    if @sensitive_word.destroy
      flash[:notice] = '敏感词删除成功'
    else
      flash[:error] = '删除失败'
    end
    redirect_to admin_sensitive_words_path
  end

  # 切换启用/禁用状态
  def toggle
    @sensitive_word.update(enabled: !@sensitive_word.enabled)
    redirect_to admin_sensitive_words_path
  end

  # 批量导入
  def import
    if request.post?
      words_text = params[:words_text]
      if words_text.present?
        words = words_text.split(/[\\n\\r,，]+/).map(&:strip).reject(&:blank?)
        
        imported_count = 0
        words.each do |word|
          sw = SensitiveWord.find_or_initialize_by(word: word.downcase)
          if sw.new_record?
            sw.severity = params[:default_severity] || 1
            sw.description = "批量导入"
            sw.enabled = true
            if sw.save
              imported_count += 1
            end
          end
        end
        
        flash[:notice] = "成功导入 #{imported_count} 个敏感词"
        redirect_to admin_sensitive_words_path
      else
        flash.now[:error] = '请输入要导入的敏感词'
      end
    end
  end

  # 内容检测工具
  def check_content
    if request.post?
      content = params[:content]
      if content.present?
        @filter_service = SensitiveWordFilterService.new(content)
        @filter_service.detect.filter
        @detection_result = {
          original_content: content,
          filtered_content: @filter_service.filtered_content,
          detected_words: @filter_service.detected_words,
          contains_sensitive: @filter_service.contains_sensitive_words?,
          max_severity: @filter_service.max_severity,
          summary: @filter_service.detection_summary
        }
      else
        flash.now[:error] = '请输入要检测的内容'
      end
    end
  end

  private

  def set_sensitive_word
    @sensitive_word = SensitiveWord.find(params[:id])
  end

  def sensitive_word_params
    params.require(:sensitive_word).permit(:word, :description, :severity, :enabled)
  end
end