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
  name: "Long Vũ",
  phone_number: Faker::PhoneNumber.cell_phone_in_e164,
  role: 0
)
main_user.skip_confirmation!
main_user.save!

users = [main_user]

9.times do
  user = User.new(
    email: Faker::Internet.unique.email,
    password: "123456",
    name: Faker::Name.name,
    phone_number: Faker::PhoneNumber.cell_phone_in_e164,
    role: rand(0..1)
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
puts "📝 Creating posts..."

posts = []
users.each do |user|
  rand(1..3).times do
    posts << Post.create!(
      user_id: user.id,
      title: Faker::Book.title,
      content: Faker::Lorem.paragraph(sentence_count: 5),
      image_url: Faker::LoremFlickr.image(size: "640x480", search_terms: ['health'])
    )
  end
end

puts "✅ Created #{posts.size} posts"

# -------------------------------------------------
# COMMENTS
# -------------------------------------------------
puts "💬 Creating comments..."

posts.each do |post|
  rand(1..4).times do
    comment = Comment.create!(
      post_id: post.id,
      user_id: users.sample.id,
      content: Faker::Lorem.sentence(word_count: 8)
    )

    # nested replies
    rand(0..2).times do
      Comment.create!(
        post_id: post.id,
        user_id: users.sample.id,
        parent_id: comment.id,
        content: Faker::Lorem.sentence(word_count: 6)
      )
    end
  end
end

puts "✅ Comments created!"

puts "🎉 Done! Seeding completed successfully."
