require "aws-sdk-s3"

class S3UploadService
  def self.upload(file, folder)
    key = File.join(folder, "#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_#{file.original_filename.parameterize}")

    s3 = Aws::S3::Client.new(
      region: ENV["AWS_REGION"],
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    )

    s3.put_object(
      bucket: ENV["AWS_BUCKET"],
      key: key,
      body: file,
      content_type: file.content_type || 'application/octet-stream',
      acl: 'public-read'
    )

    "https://#{ENV["AWS_BUCKET"]}.s3.#{ENV["AWS_REGION"]}.amazonaws.com/#{key}"
  end

  def self.delete_by_url(url)

    # Extract the key from the URL
    uri = URI.parse(url)
    key = uri.path[1..] # remove leading slash


    s3 = Aws::S3::Client.new(
      region: ENV["AWS_REGION"],
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      )

    s3.delete_object(bucket: ENV["AWS_BUCKET"], key: key)
    true
  rescue => e
    Rails.logger.error("Failed to delete S3 object: #{e.message}")
    false
  end
end