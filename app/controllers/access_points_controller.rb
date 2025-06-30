require 'csv'

class AccessPointsController < ActionController::Base
    protect_from_forgery with: :null_session  # APIと共存させるなら

    def sync
        api_key = ENV['MERAKI_API_KEY']
        org_id = ENV['MERAKI_ORG_ID']
        url = "https://api.meraki.com/api/v1/organizations/#{org_id}/devices"
        headers = {
            "X-Cisco-Meraki-API-Key" => api_key,
            "Content-Type" => "application/json"
        }

        response = HTTParty.get(url, headers: headers)

        CSV.open("storage/meraki_data/access_points.csv", "w") do |csv|
            csv << %w[name mac serial network_id model] # ヘッダー行
            response.parsed_response.each do |device|
                next unless device["model"].start_with?("MR")

                csv << [
                device["name"],
                device["mac"],
                device["serial"],
                device["networkId"],
                device["model"]
                ]
            end
        end

        render json: { status: "ok", message: "APをCSVに保存しました" }
    end

    def index
        @access_points = CSV.read("storage/meraki_data/access_points.csv", headers: true)
        render :index
    end
end
