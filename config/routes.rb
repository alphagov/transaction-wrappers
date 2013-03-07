TransactionWrappers::Application.routes.draw do
  get "/:slug" => "epdq_transactions#start"
end
