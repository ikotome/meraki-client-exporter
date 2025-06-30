Rails.application.routes.draw do
  # HTMLページ表示
  get '/access_points', to: 'access_points#index'

  # MerakiのAP一覧をCSVに保存する用
  get '/access_points/sync', to: 'access_points#sync'
end
