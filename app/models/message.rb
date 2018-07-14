class Message < ApplicationRecord
  SHORT_TYPE = 'emotion'.freeze
  REGULAR_TYPE = 'text'.freeze
  PAYLOAD_RANGES = {
    SHORT_TYPE => [2, 10],
    REGULAR_TYPE => [1, 160]
  }.freeze
  MESSAGE_TYPES = PAYLOAD_RANGES.keys.freeze

  enum message_type: MESSAGE_TYPES
  validates :message_type, presence: true, inclusion: { in: MESSAGE_TYPES }
  validates :payload, presence: true
  validate :payload_length
  validate :payload_no_digits, if: -> { message_type == SHORT_TYPE }

  private

  def payload_length
    errors.add(:payload, "Size not in #{payload_range}") if payload_out_of_range?
  end

  def payload_range
    PAYLOAD_RANGES[message_type]
  end

  def payload_out_of_range?
    return false unless payload
    !payload.size.between? *payload_range
  end

  def payload_no_digits
    errors.add(:payload, "#{SHORT_TYPE} type can't contain any digits") if payload_with_digits?
  end

  def payload_with_digits?
    return false unless payload
    !!(payload =~ /\d/)
  end
end
