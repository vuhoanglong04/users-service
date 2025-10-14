class SyncDataToElasticsearchJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Post.import(force: true)
    User.import(force: true)
    DoctorProfile.import(force: true)
    PatientProfile.import(force: true)
    Billing.import(force: true)
  end
end
