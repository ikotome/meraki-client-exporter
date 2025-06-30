require 'csv'

class DashboardController < ApplicationController
  def index
    # AP一覧読み込み
    ap_list = CSV.read("storage/meraki_data/access_points.csv", headers: true)

    # クライアントログ読み込み
    client_logs = CSV.read("storage/meraki_data/client_logs.csv", headers: true)

    # APごとの接続数を集計
    @ap_counts = ap_list.map do |ap|
      count = client_logs.count { |log| log["access_point_serial"] == ap["serial"] }
      ["#{ap["name"]} (#{ap["model"]})", count]
    end.to_h

    # APごとの時系列グラフ用データ（ダミー生成。last_seenを時間にまとめるなら別途加工が必要）
    @ap_timeseries = {}

    ap_list.each do |ap|
      logs = client_logs.select { |log| log["access_point_serial"] == ap["serial"] }
      data = logs.map do |log|
        t = Time.at(log["last_seen"].to_i).strftime("%Y-%m-%d %H:%M")
        [t, log["usage"].to_i]
      end

      @ap_timeseries[ap["name"]] = data
    end
  end
end
