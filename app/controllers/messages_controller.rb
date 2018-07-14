class MessagesController < ActionController::API
  def create
    render json: { message: 'everything is fine. calm down' }
  end
end
