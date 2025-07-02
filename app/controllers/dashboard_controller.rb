# app/controllers/dashboard_controller.rb
require "csv"

class DashboardController < ApplicationController
  def index
    ap_list = CSV.read(Rails.root.join("storage/meraki_data/access_points.csv"), headers: true)
    client_logs = CSV.read(Rails.root.join("storage/meraki_data/client_logs.csv"), headers: true)

    # APごとのクライアント数（棒グラフ）
    @ap_counts = ap_list.map do |ap|
      count = client_logs.count { |log| log["access_point_serial"] == ap["serial"] }
      [ "#{ap["name"]} (#{ap["model"]})", count ]
    end.to_h

    # APごとの通信量（時系列グラフ）
    @ap_timeseries = {}

    ap_list.each do |ap|
      logs = client_logs.select { |log| log["access_point_serial"] == ap["serial"] }

      data = logs.map do |log|
        next if log["last_seen"].blank?

        begin
          time = Time.at(log["last_seen"].to_i).strftime("%Y-%m-%d %H:%M")
          [ time, log["usage"].to_i ]
        rescue
          nil
        end
      end.compact

      @ap_timeseries[ap["name"]] = data
    end
  end
end
