require 'net/http'
require 'uri'
require 'csv'

def parse(line)
  line = line.strip
  tokens = line.split(',')
  return [-1, 0, 0, 0, 0, 0] unless tokens[0] == "$GPGGA"
  return [-3, 0, 0, 0, 0, 0] unless [9, 15].include?(tokens.length)

  if tokens.length == 15
    message_id, utc, lat, sn, lon, we, gps_quality, svs, hdop, height, height_unit, geoid_sep, geoid_sep_meters, age, station_id_ctrl = tokens
  else
    message_id, utc, lat, sn, lon, we, gps_quality, svs, station_id_ctrl = tokens
  end

  station_id, ctrl = station_id_ctrl.split('*')

  checksum = line[1..-4].chars.reduce(0) { |sum, ch| sum ^ ch.ord }
  checksum_str = checksum.to_s(16).upcase.rjust(2, '0')
  return [-2, 0, 0, 0, 0, 0, 0] if checksum_str != ctrl

  hour = utc[0, 2].to_f
  minute = utc[2, 2].to_f
  sec = utc[4..-1].to_f

  lat_dg = lat[0, 2].to_i
  lat_min = lat[2..-1].to_f
  latitude = lat_dg + lat_min / 60.0
  latitude *= -1 if sn == 'S'

  lon_dg = lon[0, 3].to_i
  lon_min = lon[3..-1].to_f
  longitude = lon_dg + lon_min / 60.0
  longitude *= -1 if we == 'W'

  [0, hour, minute, sec, latitude, longitude, height]
end

def parse_lines(lines)
  lines.map { |line| parse(line) }.select { |parsed| parsed[0] == 0 }
end

def parse_file(filename)
  parse_lines(File.readlines(filename))
end

def parse_bytes(filename)
  chars = CSV.read(filename)
  string = ''
  chars[0].each { |char| 
    val = char.to_i
    str = val.ord.chr
    string = string + str
  }

  parse_lines(string.lines)
end

def calculate_center(values)
  values.sum / values.size.to_f
end

def generate_static_map(filename, image_filename, api_key)
  lines = File.readlines(filename)
  parsed_data = parse_lines(lines)
  lats = parsed_data.map { |line| line[-3] }
  lons = parsed_data.map { |line| line[-2] }

  center_lat = calculate_center(lats)
  center_lon = calculate_center(lons)
  center = "#{center_lat},#{center_lon}"
  zoom = '13'
  size = '600x300'
  mtype = 'roadmap'
  markers = lats.each_with_index.map { |lat, i| "color:blue%7Clabel:#{i}%7C#{lat},#{lons[i]}" }
  
  uri = URI("https://maps.googleapis.com/maps/api/staticmap?center=#{center}&zoom=#{zoom}&size=#{size}&maptype=#{mtype}&key=#{api_key}")
  markers.each { |marker| uri.query += "&markers=#{marker}" }
  
  response = Net::HTTP.get_response(uri)
  File.open(image_filename, 'wb') { |file| file.write(response.body) } if response.is_a?(Net::HTTPSuccess)
end

def main
  parse_bytes('test_files/bytes.nmea').each { |position| puts position.inspect }
end

main if __FILE__ == $PROGRAM_NAME
