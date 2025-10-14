# frozen_string_literal: true

require 'faker'

puts "🧹 Clearing existing data..."
Comment.delete_all
Post.delete_all
Appointment.delete_all
DoctorProfile.delete_all
PatientProfile.delete_all
User.delete_all

puts "🌱 Seeding data..."

# -------------------------------------------------
# USERS
# -------------------------------------------------
puts "👤 Creating users..."

main_user = User.new(
  email: "longvulinhhoang@gmail.com",
  password: "123456",
  first_name: "Long",
  last_name: "Vu",
  phone_number: Faker::PhoneNumber.cell_phone_in_e164,
  role: 0,
  avatar: Faker::Avatar.image
)
main_user.skip_confirmation!
main_user.save!

users = [main_user]

9.times do
  user = User.new(
    email: Faker::Internet.unique.email,
    password: "123456",
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    phone_number: Faker::PhoneNumber.cell_phone_in_e164,
    role: rand(0..1),
    avatar: Faker::Avatar.image
  )
  user.skip_confirmation!
  user.save!
  users << user
end

puts "✅ Created #{users.size} users"

# -------------------------------------------------
# DOCTOR PROFILES
# -------------------------------------------------
puts "👨‍⚕️ Creating doctor profiles..."

doctors = users.sample(5)
doctor_profiles = doctors.map do |user|
  DoctorProfile.create!(
    user_id: user.id,
    specialization: Faker::Job.field,
    license_number: Faker::Number.number(digits: 8),
    experience_years: rand(1..20),
    bio: Faker::Lorem.paragraph(sentence_count: 3)
  )
end

puts "✅ Created #{doctor_profiles.size} doctor profiles"

# -------------------------------------------------
# PATIENT PROFILES
# -------------------------------------------------
puts "🧍 Creating patient profiles..."

patients = users.sample(7)
patient_profiles = patients.map do |user|
  PatientProfile.create!(
    user_id: user.id,
    date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 65),
    gender: %w[male female].sample,
    address: Faker::Address.full_address,
    emergency_contact: Faker::PhoneNumber.cell_phone_in_e164,
    medical_history: Faker::Lorem.sentence(word_count: 10)
  )
end

puts "✅ Created #{patient_profiles.size} patient profiles"

# -------------------------------------------------
# APPOINTMENTS
# -------------------------------------------------
puts "📅 Creating appointments..."

20.times do
  Appointment.create!(
    doctor_id: doctor_profiles.sample.id,
    patient_id: patient_profiles.sample.id,
    appointment_date: Faker::Time.forward(days: rand(1..30), period: :morning),
    status: %w[pending confirmed cancelled completed].sample,
    notes: Faker::Lorem.sentence(word_count: 10)
  )
end

puts "✅ Created 20 appointments"

# -------------------------------------------------
# POSTS
# -------------------------------------------------
puts "📝 Creating 10,000 posts..."

users = User.pluck(:id)
posts = []

10_000.times do |i|
  posts << {
    user_id: rand(1..3),
    title: "#{Faker::Book.title} #{i + 1}",
    content: Faker::Lorem.paragraph(sentence_count: 5),
    image_url: Faker::LoremFlickr.image(size: "640x480", search_terms: ['health'])
  }
end

# Batch insert (MUCH faster than 10k individual create! calls)
Post.insert_all(posts)

puts "✅ Created #{posts.size} posts successfully!"

# -------------------------------------------------
# COMMENTS
# -------------------------------------------------
puts "💬 Creating comments..."

posts.each do |post|
  post_id = rand(1...10)
  user_id = rand(1...10)
  parent_comment = Comment.create!(
    post_id: post_id,
    user_id: user_id,
    content: Faker::Lorem.sentence(word_count: 8)
  )

  # nested replies
  parent_comment.children.create!(
    post_id: post_id,
    user_id: user_id,
    content: Faker::Lorem.sentence(word_count: 6)
  )
end

puts "✅ Comments created!"
# Assuming you already have some appointments, doctors, and patients in DB
puts "Creating fake billings..."

# Get random IDs to link
appointments = Appointment.pluck(:id)
doctors = DoctorProfile.pluck(:id)
patients = PatientProfile.pluck(:id)

statuses = %w[unpaid paid cancelled refunded]
payment_methods = %w[cash credit_card bank_transfer insurance online]

10.times do
  Billing.create!(
    appointment_id: appointments.sample,
    patient_id: patients.sample,
    amount: rand(20..200) * 10.0, # random amount between 200–2000
    status: statuses.sample,
    payment_method: payment_methods.sample,
    created_at: Faker::Time.between(from: 2.months.ago, to: Time.now),
    updated_at: Time.now
  )
end

puts "✅ Done! Created 10 fake billings."

puts "🎉 Done! Seeding completed successfully."
