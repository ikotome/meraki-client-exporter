require "csv"

# Merakiのアクセスポイントを取得・保存・表示するコントローラ
class AccessPointsController < ActionController::Base
  # フォームからでなくAPI経由のPOSTも受け付けるためCSRF保護を無効化（必要に応じて）
  protect_from_forgery with: :null_session

  # Meraki APIからアクセスポイント（MRシリーズ）を取得し、CSVに保存する
  def sync
    # APIキーと組織IDを環境変数から取得
    api_key = ENV["MERAKI_API_KEY"]
    org_id = ENV["MERAKI_ORG_ID"]

    # Meraki APIのURL（組織のすべてのデバイスを取得）
    url = "https://api.meraki.com/api/v1/organizations/#{org_id}/devices"

    # APIリクエストのヘッダー（認証情報）
    headers = {
      "X-Cisco-Meraki-API-Key" => api_key,
      "Content-Type" => "application/json"
    }

    # デバイス情報を取得
    response = HTTParty.get(url, headers: headers)

    # 出力用CSVファイルをオープン（上書き保存）
    CSV.open("storage/meraki_data/access_points.csv", "w") do |csv|
      # ヘッダー行を書き込み
      csv << %w[name mac serial network_id model]

      # 各デバイスをチェックして、MR（アクセスポイント）だけを対象にする
      response.parsed_response.each do |device|
        next unless device["model"].start_with?("MR")  # アクセスポイントのみ対象

        # デバイス情報をCSVに書き込み
        csv << [
          device["name"],
          device["mac"],
          device["serial"],
          device["networkId"],
          device["model"]
        ]
      end
    end

    # レスポンスとしてJSONを返す
    render json: { status: "ok", message: "APをCSVに保存しました" }
  end

  # 保存されたアクセスポイント一覧を表示する（ビューが必要）
  def index
    # CSVファイルを読み込み、@access_points に格納（ビューで使用するため）
    @access_points = CSV.read("storage/meraki_data/access_points.csv", headers: true)

    # indexビューを描画（例: app/views/access_points/index.html.erb）
    render :index
  end
end
