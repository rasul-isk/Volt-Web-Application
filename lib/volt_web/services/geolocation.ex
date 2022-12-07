defmodule Volt.Geolocation do

  def find_location(address) do
    uri = "http://dev.virtualearth.net/REST/v1/Locations?q=1#{URI.encode(address)}%&key=#{get_key()}"
    response = HTTPoison.get! uri
    matches = Regex.named_captures(~r/coordinates\D+(?<lat>-?\d+.\d+)\D+(?<long>-?\d+.\d+)/, response.body)
    if(matches["lat"] != nil &&  matches["long"] != nil) do
      [{v1, _}, {v2, _}] = [matches["lat"] |> Float.parse, matches["long"] |> Float.parse]
      [v1, v2]
    else
      [nil,nil]
     end
  end

  def distance(origin, destination) do
    [o1, o2] = find_location(origin)
    [d1, d2] = find_location(destination)
    if(o1 && o2 && d1 && d2) do
      uri = "https://dev.virtualearth.net/REST/v1/Routes/DistanceMatrix?origins=#{o1},#{o2}&destinations=#{d1},#{d2}&travelMode=driving&key=#{get_key()}"
      response = HTTPoison.get! uri
      matches = Regex.named_captures(~r/travelD\D+(?<dist>\d+.\d+)\D+(?<dur>\d+.\d+)/,response.body)
      if(matches["dist"] != nil &&  matches["dur"] != nil) do
        [{v1, _}, {v2, _}] = [matches["dist"] |> Float.parse, matches["dur"] |> Float.parse]
        [v1, v2]
      else
      [nil,nil]
      end
    else
      [nil,nil]
    end

    #  Distance | Duration
  end

  def distance_Modified(lat, long, destination) do
     [o1, o2] = [lat,long]
     [d1, d2] = find_location(destination)
     uri = "https://dev.virtualearth.net/REST/v1/Routes/DistanceMatrix?origins=#{o1},#{o2}&destinations=#{d1},#{d2}&travelMode=driving&key=#{get_key()}"
     response = HTTPoison.get! uri
     matches = Regex.named_captures(~r/travelD\D+(?<dist>\d+.\d+)\D+(?<dur>\d+.\d+)/,response.body)
    #  throw matches["dist"]
     if(matches["dist"] != nil &&  matches["dur"] != nil) do
      [{v1, _}, {v2, _}] = [matches["dist"] |> Float.parse, matches["dur"] |> Float.parse]
      [v1, v2]
     else
      [nil,nil]
     end
    #  Distance | Duration
  end

  def calculate_fee(origin, destination) do
    [dist, _] = distance(origin, destination)
    Float.ceil(dist*0.5+1.5,2)
    # distance*50 cent per km + minimum 2.5 euro | with rounding of 2 digits
  end

  def address_valid(address) do
    [lat,long] = Volt.Geolocation.find_location(address)
    address_valid = address |> String.split(",") |> length() == 3
    lat != nil && long != nil && address_valid
  end

  def address_valid_soft(address) do
    [lat,long] = Volt.Geolocation.find_location(address)
    lat != nil && long != nil
  end


  defp get_key(), do: "API-KEY"
end
