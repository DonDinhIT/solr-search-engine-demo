class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
    # All posts with a `text` field (:title, :content, or :comments) containing params[:search]
    @search1 = Post.search do
      fulltext "post"
      with(:published_at).less_than(Time.zone.now)
      facet(:publish_month)
      with(:publish_month, params[:month]) if params[:month].present?
    end
    @results1 = @search1.results

    # Posts with params[:search], params[:search] appears in the title
    @search2 =  Post.search do
      fulltext "post" do
        fields(:title)
      end
    end
    @results2 = @search2.results
    
    # Posts with post in the title (boosted) or in the body (not boosted)
    @search3 = Post.search do
      fulltext 'post' do
        fields(:content, :title => 2.0)
      end
    end
    @results3 = @search3.results

    # Posts with the exact phrase "keyword search"
    @search4 = Post.search do
      fulltext '"Posts in"'
    end

    @results4 = @search4.results

    # Posts with the exact phrase "keyword search", query_phrase_slop sets the number of words that may appear between the words in a phrase.
    @search5 = Post.search do
      fulltext '"with in"' do
        query_phrase_slop 2
      end
    end
    @results5 = @search5.results

  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)
    @post.published_at = Time.now
    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render action: 'show', status: :created, location: @post }
      else
        format.html { render action: 'new' }
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
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :content)
    end
end
