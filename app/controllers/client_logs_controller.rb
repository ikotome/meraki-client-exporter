class ClientLogsController < ApplicationController
  def sync
    # ...APIから取得...

    all_logs = []

    AccessPointsController.load_access_points.each do |ap|
      url = "https://api.meraki.com/api/v1/devices/#{ap["serial"]}/clients"
      response = HTTParty.get(url, headers: headers)
      clients = response.parsed_response

      logs = clients.map do |c|
        {
          access_point_serial: ap["serial"],
          mac: c["mac"],
          ip: c["ip"],
          last_seen: c["lastSeen"],
          usage: c["usage"]&.dig("total") || 0
        }
      end

      all_logs += logs
    end

    File.write("storage/meraki_data/client_logs.json", JSON.pretty_generate(all_logs))
    render json: { status: "ok", total_logs: all_logs.size }
  end
end
