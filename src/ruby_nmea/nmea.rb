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

def parse_bytes_string(chars)
  string = ''
  chars.each { |char| 
    val = char.to_i
    str = val.ord.chr
    string = string + str
  }

  parse_lines(string.lines)
end
def parse_bytes_file(filename)
  chars = CSV.read(filename)
  parse_bytes_string(chars[0])
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
  parse_bytes_file('test_files/bytes.nmea').each { |position| puts position.inspect }
  data = '48, 48, 44, 65, 44, 53, 50, 48, 49, 46, 54, 49, 56, 49, 51, 44, 78, 44, 48, 50, 48, 52, 52, 46, 55, 57, 49, 52, 56, 44, 69, 44, 49, 46, 53, 51, 57, 44, 44, 49, 56, 48, 49, 50, 53, 44, 44, 44, 65, 42, 55, 57, 13, 10, 36, 71, 80, 86, 84, 71, 44, 44, 84, 44, 44, 77, 44, 49, 46, 53, 51, 57, 44, 78, 44, 50, 46, 56, 53, 49, 44, 75, 44, 65, 42, 50, 51, 13, 10, 36, 71, 80, 71, 71, 65, 44, 50, 49, 52, 50, 48, 55, 46, 48, 48, 44, 53, 50, 48, 49, 46, 54, 49, 56, 49, 51, 44, 78, 44, 48, 50, 48, 52, 52, 46, 55, 57, 49, 52, 56, 44, 69, 44, 49, 44, 48, 52, 44, 52, 46, 48, 52, 44, 49, 52, 49, 46, 56, 44, 77, 44, 51, 52, 46, 57, 44, 77, 44, 44, 42, 53, 50, 13, 10, 36, 71, 80, 71, 83, 65, 44, 65, 44, 51, 44, 48, 50, 44, 51, 50, 44, 49, 52, 44, 49, 48, 44, 44, 44, 44, 44, 44, 44, 44, 44, 53, 46, 54, 55, 44, 52, 46, 48, 52, 44, 51, 46, 57, 55, 42, 48, 67, 13, 10, 36, 71, 80, 71, 83, 86, 44, 51, 44, 49, 44, 49, 49, 44, 48, 49, 44, 53, 48, 44, 50, 56, 56, 44, 49, 50, 44, 48, 50, 44, 53, 54, 44, 50, 57, 51, 44, 50, 49, 44, 48, 51, 44, 76, 76, 44, 53, 50, 48, 49, 46, 54, 49, 50, 48, 53, 44, 78, 44, 48, 50, 48, 52, 52, 46, 55, 57, 49, 57, 56, 44, 69, 44, 50, 49, 52, 50, 53, 49, 46, 48, 48, 44, 65, 44, 65, 42, 54, 50, 13, 10, 36, 71, 80, 82, 77, 67, 44, 50, 49, 52, 50, 53, 50, 46, 48, 48, 44, 65, 44, 53, 50, 48, 49, 46, 54, 49, 49, 56, 56, 44, 78, 44, 48, 50, 48, 52, 52, 46, 55, 57, 50, 48, 49, 44, 69, 44, 48, 46, 50, 51, 49, 44, 44, 49, 56, 48, 49, 50, 53, 44, 44, 44, 65, 42, 55, 50, 13, 10, 36, 71, 80, 86, 84, 71, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0'.split(",")
  parse_bytes_string(data).each { |position| puts position.inspect }
end

main if __FILE__ == $PROGRAM_NAME
