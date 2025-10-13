class Api::V1::Admin::PostsController < Api::V1::Admin::BaseAdminController
  def index
    page = params[:page] ||= 1
    posts = Post.with_deleted.all.page(page).per(5)
    render_response(
      data: {
        posts: ActiveModelSerializers::SerializableResource.new(posts, each_serializer: Admin::PostSerializer)
      },
      message: "Get all posts successfully",
      status: 200,
      meta: pagination_meta(posts)
    )
  end

  def create
    CreatePostForm.new(post_params)
    image_url = S3UploadService.upload(post_params[:image_url], "posts")
    post = Post.new(post_params.except(:image_url).merge(image_url: image_url))
    if post.save
      render_response(
        data: {
          post: ActiveModelSerializers::SerializableResource.new(post, serializer: Admin::PostSerializer)
        },
        message: "Create post successfully",
        status: 201
      )
    else
      raise ValidationError.new("Validation failed", post.errors)
    end
  end

  def update
    UpdatePostForm.new(post_params)
    post = Post.with_deleted.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "Post not found" if post.nil?
    if post_params[:image_url]
      image_url = S3UploadService.upload(post_params[:image_url], "posts")
    end
    if post.update(
      image_url ?
        post_params.except(:image_url).merge(image_url: image_url) :
        post_params
    )
      render_response(
        data: {
          post: ActiveModelSerializers::SerializableResource.new(post, serializer: Admin::PostSerializer)
        },
        message: "Update post successfully",
        status: 200
      )
    else
      raise ValidationError.new("Validation failed", post.errors)
    end
  end

  def destroy
    post = Post.without_deleted.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "Post not found" if post.nil?
    post.destroy
    render_response(message: "Post deleted", status: 200)
  end

  def restore
    post = Post.only_deleted.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "Post not found" if post.nil?
    Post.restore(params[:id])
    render_response(message: "Post restored", status: 200)
  end

  private

  def post_params
    params.permit(:user_id, :title, :content, :image_url)
  end
end
