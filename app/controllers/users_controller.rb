class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:destroy, :basic_info_edit, :basic_info ,:index]

  def index
    
    @users = User.paginate(page: params[:page])

  end
  
  def show
    

    if current_user.admin?
      @user = User.find(params[:id])
    else
      @user = current_user
    end
    # 曜日表示用に使用する
    @youbi = %w[日 月 火 水 木 金 土]
    
    #基本情報
    @basic_info = BasicInfo.find_by(id: 1)
    
    # 既に表示月があれば、表示月を取得する
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      # 表示月が無ければ、今月分を表示
      @first_day = Date.new(Date.today.year, Date.today.month, 1)
    end
    #最終日を取得する
    @last_day = @first_day.end_of_month

    # 今月の初日から最終日の期間分を取得
    (@first_day..@last_day).each do |date|
      # 該当日付のデータがないなら作成する
      #(例)user1に対して、今月の初日から最終日の値を取得する
      if !@user.attendances.any? {|attendance| attendance.day == date }
        linked_attendance = Attendance.create(user_id: @user.id, day: date)
        linked_attendance.save
      end
    end
    # 表示期間の勤怠データを日付順にソートして取得 show.html.erb、 <% @attendances.each do |attendance| %>からの情報
    @attendances = @user.attendances.where('day >= ? and day <= ?', @first_day, @last_day).order("day ASC")
  end
  
  
  def basic_info
    if params[:id].nil?
      @user  = User.find(current_user.id)
    else
      @user  = User.find(params[:id])
    end
  end

  def basic_info_edit
    
    @user  = User.find(params[:id])
    
    if @user.update_attributes(user_params)
      flash[:success] = "基本情報を更新しました。"
      redirect_to @user
    else
      redirect_to @user
    end
  end
  
  
  
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
    #  @user.send_activation_email
     # flash[:info] = "あなたのアカウントをアクティブにするためメールしました。確認してください"
    #  redirect_to root_url
      log_in@user
      flash[:success]="ようこそ"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find_by(id: params[:id])
    
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "プロフィールが更新されました"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "ユーザーを削除しました"
    redirect_to users_url
  end
  

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,:shozoku,
                                   :basic_work_time, :specified_work_time, :password_confirmation)
    end
    
    # beforeアクション
    
    # ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in?
         store_location
        flash[:danger] = "ログインしてください"
        redirect_to login_url
      end
    end
    
        # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    # 管理者かどうか確認
    def admin_user
     redirect_to(root_url) unless current_user.admin?
    end
    
end