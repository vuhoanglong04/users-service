# frozen_string_literal: true

class EmailProducer
  def self.send_email(payload)
    producer = $kafka.async_producer(delivery_interval: 5)
    producer.produce(payload.to_json, topic: "email")
    producer.deliver_messages
  end
end
