class Message < ApplicationRecord
  enum message_type: %i(emotion text)
end
