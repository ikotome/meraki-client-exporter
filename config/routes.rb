Rails.application.routes.draw do
  # HTMLページ表示
  get '/access_points', to: 'access_points#index'
  # get '/client_logs', to: 'client_logs#index'
  get '/dashboard', to: 'dashboard#index'

  # MerakiのAP一覧をCSVに保存する用
  get '/access_points/sync', to: 'access_points#sync'
  # クライアントログをCSVに保存する用
  get '/client_logs/sync', to: 'client_logs#sync'

end
