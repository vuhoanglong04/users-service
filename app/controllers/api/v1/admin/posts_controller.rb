class Api::V1::Admin::PostsController < Api::V1::Admin::BaseAdminController
  def index
    page = params[:page].to_i >= 1 ? params[:page].to_i : 1
    per_page = 5
    query = params[:query].to_s.strip

    cache_key = [
      "post_page=#{page}",
      "per_page=#{per_page}",
      "query=#{query}",
    ].compact.join("&")

    Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      results = Post.search(
        {
          from: (page - 1) * per_page,
          size: per_page,
          query: query.present? ?
                   { multi_match: { query: query, fields: %w[title content] } } :
                   { match_all: {} }
        }
      )

      meta = es_pagination_meta(results.response, page, per_page)

      serialized_posts = ActiveModelSerializers::SerializableResource.new(
        results.records,
        each_serializer: Admin::PostSerializer
      ).as_json

      {
        data: { posts: serialized_posts },
        meta: meta
      }
    end.then do |cached_response|
      render_response(
        data: cached_response[:data],
        message: "Get all posts successfully",
        status: 200,
        meta: cached_response[:meta]
      )
    end
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
