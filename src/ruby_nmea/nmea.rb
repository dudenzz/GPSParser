require 'net/http'
require 'uri'

def parse(line)
  line = line.strip
  tokens = line.split(',')
  return [-1, 0, 0, 0, 0, 0] if tokens[0] != "$GPGGA"
  return [-3, 0, 0, 0, 0, 0] unless [9, 15].include?(tokens.length)

  if tokens.length == 15
    message_id, utc, lat, sn, lon, we, gps_quality, svs, hdop, height, height_unit, geoid_sep, geoid_sep_meters, age, station_id_ctrl = tokens
  elsif tokens.length == 9
    message_id, utc, lat, sn, lon, we, gps_quality, svs, station_id_ctrl = tokens
  end

  station_id, ctrl = station_id_ctrl.split('*')

  checksum = 0
  line[1..-4].each_char { |ch| checksum ^= ch.ord }

  nibble1 = (checksum / 16).to_i
  nibble1 = case nibble1
            when 10 then 'A'
            when 11 then 'B'
            when 12 then 'C'
            when 13 then 'D'
            when 14 then 'E'
            when 15 then 'F'
            else nibble1.to_s
            end

  nibble2 = checksum % 16
  nibble2 = case nibble2
            when 10 then 'A'
            when 11 then 'B'
            when 12 then 'C'
            when 13 then 'D'
            when 14 then 'E'
            when 15 then 'F'
            else nibble2.to_s
            end

  checksum_str = "#{nibble1}#{nibble2}"
  if checksum_str != ctrl
    puts "#{checksum_str} #{ctrl}"
    return [-2, 0, 0, 0, 0, 0]
  end

  hour = utc[0..1].to_f
  minute = utc[2..3].to_f
  sec = utc[4..].to_f

  lat_deg = lat[0..1].to_i
  lat_min = lat[2..].to_f
  latitude = lat_deg + lat_min / 60.0
  latitude *= -1 if sn == 'S'

  lon_deg = lon[0..2].to_i
  lon_min = lon[3..].to_f
  longitude = lon_deg + lon_min / 60.0
  longitude *= -1 if we == 'W'

  [0, hour, minute, sec, latitude, longitude, height.to_f]
end

def parse_lines(lines)
  lines.each_with_object([]) do |line, output|
    parsed = parse(line)
    output << parsed if parsed[0] == 0
  end
end

def parse_file(filename)
  lines = File.readlines(filename)
  parse_lines(lines)
end

def calculate_center(values)
  values.sum / values.size.to_f
end

def generate_static_map(filename, image_filename, api_key)
  lines = File.readlines(filename)
  lats, lons = [], []

  parse_lines(lines).each do |parsed_line|
    lats << parsed_line[-3]
    lons << parsed_line[-2]
  end

  center_lat = calculate_center(lats)
  center_lon = calculate_center(lons)
  center = "#{center_lat},#{center_lon}"
  zoom = '13'
  size = '600x300'
  map_type = 'roadmap'
  markers = lats.each_with_index.map { |lat, i| "color:blue|label:#{i}|#{lat},#{lons[i]}" }

  uri = URI("https://maps.googleapis.com/maps/api/staticmap")
  params = {
    center: center,
    zoom: zoom,
    size: size,
    maptype: map_type,
    key: api_key
  }
  markers.each { |marker| uri.query += "&markers=#{URI.encode_www_form_component(marker)}" }

  response = Net::HTTP.get_response(uri)
  if response.is_a?(Net::HTTPSuccess)
    File.open(image_filename, 'wb') { |file| file.write(response.body) }
  end
end

def main
  parse_file('test_files/ryszard.nmea').each do |line|
    puts line.inspect
  end
end

if __FILE__ == $PROGRAM_NAME
  main
end