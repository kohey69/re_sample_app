class MicropostsController < ApplicationController
before_action :logged_in_user, only: [:create, :destroy]
before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = "投稿完了！"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home', status: :unprocessable_entity       
    end
  end

  def destroy
      @micropost.destroy
      flash[:success] = "投稿を削除しました"
      if request.referrer.nil? # 直前のURLが存在する時
        redirect_to root_url, status: :see_other
      else
        redirect_to request.referrer, status: :see_other
      end
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content, :image)
  end

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id]) # 現在ログイン中のユーザーのマイクロポストを返す
    redirect_to root_url, status: :see_other if @micropost.nil? # @micropostがnilの時root_urlにリダイレクトし、
                                                                # ステータスコードをseeotherに指定する(turbo互換性のため)
  end

end
