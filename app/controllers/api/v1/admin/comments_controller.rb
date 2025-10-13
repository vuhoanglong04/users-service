class Api::V1::Admin::CommentsController < Api::V1::Admin::BaseAdminController
  def destroy
    comment = Comment.without_deleted.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "Comment not found" if comment.nil?
    comment.destroy
    render_response(message: "Comment deleted", status: 200)
  end

  def restore
    comment = Comment.without_deleted.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "Comment not found" if comment.nil?
    Comment.restore(params[:id])
    render_response(message: "Comment restored", status: 200)
  end
end
