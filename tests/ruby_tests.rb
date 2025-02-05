require_relative '../src/ruby_nmea/nmea'

parse_bytes('test_files/bytes.nmea').each { |position| puts position.inspect }