$kafka = Kafka.new(
  seed_brokers: ENV["KAFKA_BROKER"],
  client_id: "healthcare-main-app"
)
p $kafka
unless $kafka.topics.include?("email")
  $kafka.create_topic("email", num_partitions: 1, replication_factor: 1)
end