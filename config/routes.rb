Rails.application.routes.draw do
  # NOTE: Omitting the /api/v1/ convention
  # as not needed for this simple app
  post 'messages/:type' => 'messages#create'
end
