class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  def index
    @posts = Post.all.order('created_at DESC')
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    respond_to do |format|
      if @post.save
        # FilterObscenity.new.perform(@post.id)
        FilterObscenityJob.perform_later(@post.id)
        format.html { redirect_to @post, notice: 'Post was successfully created'}
        format.json { render :show, status: :created, location: @post}
      else
        format.html { render :new}
        format.json { render json: @post.errors, status: :unprocessable_entity}
      end
    end
  end

  def show
    @post =Post.find(params[:id])
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])

    if @post.update(params[:post].permit(:title, :body))
      redirect_to @post
    else
      render 'edit'
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to root_path
  end

  private
  def post_params
    params.require(:post).permit(:title, :body)
  end

end
