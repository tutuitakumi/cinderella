class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :set_time, only: [:index, :show, :new , :create, :evaluation, :conf]
  before_action :login?

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.where(user_id: current_user.id).order("created_at DESC")
    logger.debug(@posts)
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    unless @post.user_id==current_user.id
      redirect_to '/posts' , notice: "それ他の人の投稿ですよ！！！！"
    end
  end

  # GET /posts/new
  def new
    @post = Post.new
    unless @nowTime.hour ==23
      redirect_to '/posts' , notice: "まだ振り返るには早すぎる…"
    end
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    logger.debug(post_params)
    @post = Post.new(post_params)
    respond_to do |format|
      if @post.save
        current_user.post_cnt +=1
        current_user.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    @posts=Post.where('title LIKE(?)', "%#{params[:keyword]}%").order("created_at DESC")
    if @posts
      logger.debug("success!!")
    end
    render json: @posts
  end

  def evaluation
    month_post=Post.where(user_id: current_user.id).where(month: @nowTime.month)
    #logger.debug(month_post.pluck(:evaluation))
    cnt = month_post.size
    @percent= cnt * 100 / @nowTime.day
    gon.day=@month_days[@nowTime.month]
    days=month_post.pluck(:day)
    evl=month_post.pluck(:evaluation)
    j=0
    gon.data = []
    for i in 0..@nowTime.day-1 do
      if i+1==days[j]
        gon.data[i]=evl[j]
        j+=1
      else
        gon.data[i]=0
      end
    end
  end

  def conf

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:content, :title, :month, :day, :evaluation,:user_id)
    end

    def set_time
      require"date"
      @nowTime = DateTime.now
      @month_days=[0,31,28,31,30,31,30,31,31,30,31,30,31]
    end

    def login?
      unless user_signed_in?
        redirect_to "/users/sign_in", :flash => {notice: "ログインしてください"}
      end
    end

end
