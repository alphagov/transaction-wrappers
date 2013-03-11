TransactionWrappers::Application.routes.draw do
  get "/:slug" => "epdq_transactions#start", :as => :transaction
  post "/:slug/confirm" => "epdq_transactions#confirm", :as => :transaction_confirm
  get "/:slug/done" => "epdq_transactions#done", :as => :transaction_done

  root :to => "epdq_transactions#index"
end
