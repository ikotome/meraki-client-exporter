require "httparty"
require "csv"

# Meraki クライアントログをCSVに保存する非同期ジョブ
class ClientLogSyncJob < ApplicationJob
  queue_as :default

  def perform
    # Meraki APIキーを環境変数から取得
    api_key = ENV["MERAKI_API_KEY"]
    headers = {
      "X-Cisco-Meraki-API-Key" => api_key,
      "Content-Type" => "application/json"
    }
    # アクセスポイント情報をCSVから読み込む（serial列が必要）
    access_points = CSV.read("storage/meraki_data/access_points.csv", headers: true)
    # 出力ファイルを作成（クライアントログを書き込む）
    CSV.open("storage/meraki_data/client_logs.csv", "w") do |csv|
      csv << %w[access_point_serial mac ip last_seen usage] # ヘッダ行を書き込む

      # 各アクセスポイントごとにクライアント情報を取得
      access_points.each do |ap|
        url = "https://api.meraki.com/api/v1/devices/#{ap['serial']}/clients"
        response = HTTParty.get(url, headers: headers)
        clients = response.parsed_response || []

        # クライアント情報をCSVに書き込む
        clients.each do |c|
          csv << [
            ap["serial"],              # アクセスポイントのシリアル番号
            c["mac"],                  # クライアントのMACアドレス
            c["ip"],                   # クライアントのIPアドレス
            c["lastSeen"],            # 最後に観測された時刻
            c["usage"]&.dig("total") || 0  # 通信量（バイト）
          ]
        end
      end
    end
  end
end
