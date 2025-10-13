class UpdateDataElasticsearchJob < ApplicationJob
  queue_as :default

  def perform(model_name, id)
    record = model_name.constantize.find_by(id)
    if record.nil?
      $elasticsearch.delete(
        index: model_name.downcase,
        id: id
      )
    else
      $elasticsearch.index(
        index: model_name.downcase,
        id: id,
        body: record.as_json
      )
    end
  end
end
