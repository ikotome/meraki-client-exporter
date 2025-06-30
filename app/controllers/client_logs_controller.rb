require 'csv'
require 'httparty'

class ClientLogsController < ApplicationController
  def sync
    api_key = ENV['MERAKI_API_KEY']
    headers = {
      "X-Cisco-Meraki-API-Key" => api_key,
      "Content-Type" => "application/json"
    }

    # まずAP一覧をCSVから読み込み
    access_points = CSV.read("storage/meraki_data/access_points.csv", headers: true)

    CSV.open("storage/meraki_data/client_logs.csv", "w") do |csv|
      csv << %w[access_point_serial mac ip last_seen usage]

      access_points.each do |ap|
        url = "https://api.meraki.com/api/v1/devices/#{ap['serial']}/clients"
        response = HTTParty.get(url, headers: headers)

        # エラー時は空配列扱いにするなどの例外処理は必要に応じて追加
        clients = response.parsed_response || []

        clients.each do |c|
          csv << [
            ap['serial'],
            c["mac"],
            c["ip"],
            c["lastSeen"],
            c["usage"]&.dig("total") || 0
          ]
        end
      end
    end

    render json: { status: "ok", message: "クライアント情報をCSVに保存しました" }
  end

end
