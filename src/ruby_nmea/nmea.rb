require 'net/http'
require 'uri'

def parse(line)
  line = line.strip
  tokens = line.split(',')

  return [-1, 0, 0, 0, 0, 0] unless tokens[0] == "$GPGGA"
  return [-3, 0, 0, 0, 0, 0] unless [9, 15].include?(tokens.length)

  if tokens.length == 15
    message_id, utc, lat, sn, lon, we, gps_quality, svs, hdop, height, height_unit, geoid_sep, geoid_sep_meters, age, station_id_ctrl = tokens
  else
    message_id, utc, lat, sn, lon, we, gps_quality, svs, station_id_ctrl = tokens
    height = 0  # Placeholder for missing height
  end

  station_id, ctrl = station_id_ctrl.split('*')

  # Calculate checksum
  checksum = 0
  line[1..-4].each_char { |ch| checksum ^= ch.ord }
  expected_checksum = checksum.to_s(16).upcase.rjust(2, '0')

  return [-2, 0, 0, 0, 0, 0] unless expected_checksum == ctrl

  # Parse time and coordinates
  hour = utc[0, 2].to_f
  minute = utc[2, 2].to_f
  sec = utc[4..].to_f
  lat = lat[0, 2].to_i + lat[2..].to_f / 60
  lat *= -1 if sn == 'S'
  lon = lon[0, 3].to_i + lon[3..].to_f / 60
  lon *= -1 if we == 'W'

  [0, hour, minute, sec, lat, lon, height.to_f]
end

def parse_lines(lines)
  lines.map { |line| parse(line) }.select { |parsed| parsed[0] == 0 }
end

def parse_file(filename)
  lines = File.readlines(filename, chomp: true)
  parse_lines(lines)
end

def parse_bytes(filename)
  chars = eval(File.read(filename)) # Be cautious with `eval`, use JSON or another safe method if possible
  string = chars.map(&:chr).join
  puts parse_lines(string.split("\n"))
  0
end

def calculate_center(values)
  values.sum / values.length.to_f
end

def generate_static_map(filename, image_filename, api_key)
  lines = File.readlines(filename, chomp: true)
  parsed_lines = parse_lines(lines)
  
  lats = parsed_lines.map { |line| line[-3] }
  lons = parsed_lines.map { |line| line[-2] }

  center_lat = calculate_center(lats)
  center_lon = calculate_center(lons)
  center = "#{center_lat},#{center_lon}"
  zoom = "13"
  size = "600x300"
  map_type = "roadmap"

  markers = lats.each_with_index.map { |lat, i| "color:blue|label:#{i}|#{lat},#{lons[i]}" }
  request = "https://maps.googleapis.com/maps/api/staticmap?center=#{center}&zoom=#{zoom}&size=#{size}&maptype=#{map_type}"
  markers.each { |marker| request += "&markers=#{marker}" }
  request += "&key=#{api_key}"

  uri = URI(request)
  response = Net::HTTP.get(uri)

  File.open(image_filename, 'wb') { |file| file.write(response) }
end

def main
  parse_bytes('test_files/bytes.nmea')
end

main if __FILE__ == $PROGRAM_NAME
