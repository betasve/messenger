class MessagesController < ActionController::API
  ERROR_RESPONSE_CODE = 412
  SUCCESS_RESPONSE_CODE = 200
  VALID_TYPES = %w(send_emotion send_text).freeze

  def create
    render response_content
  end

  private

  def response_content
    return error_response if invalid_params? || unprocessed_message?
    success_response
  end

  def invalid_params?
    invalid_message_type? || invalid_payload?
  end

  def invalid_message_type?
    VALID_TYPES.exclude? params[:type]
  end

  def invalid_payload?
    request.GET[:payload].present? ||
      params[:payload].blank?
  end

  def unprocessed_message?
    message = Message.new(
      message_type: extracted_type,
      payload: params[:payload]
    )

    !message.save
  end

  def extracted_type
    params[:type].split('_').last
  end

  def error_response
    { status: ERROR_RESPONSE_CODE }
  end

  def success_response
    { status: SUCCESS_RESPONSE_CODE }
  end
end
