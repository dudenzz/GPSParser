import requests 
def parse(line):
    line = line.strip()
    tokens = line.split(',')
    if tokens[0] != "$GPGGA":
        return [-1,0,0,0,0,0]
    if (len(tokens)) != 15 and (len(tokens)) != 9:
        return [-3,0,0,0,0,0]
    if((len(tokens))) == 15:
        [messageId, UTC, Lat, SN, Lon, WE, GPS_quality, SVs, HDOP, height, height_unit, geoid_sep, geoid_sep_meters, age, stationID_ctrl] = tokens
    if((len(tokens))) == 9:
        [messageId, UTC, Lat, SN, Lon, WE, GPS_quality, SVs, stationID_ctrl] = tokens
    [stationID, ctrl] = stationID_ctrl.split('*')
   
    checksum = 0
    for ch in line[1:-3]:
        checksum = checksum ^ ord(ch)
    
    nibble1 = int(checksum / 16)
    if nibble1 == 10: nibble1 = 'A'
    if nibble1 == 11: nibble1 = 'B'
    if nibble1 == 12: nibble1 = 'C'
    if nibble1 == 13: nibble1 = 'D'
    if nibble1 == 14: nibble1 = 'E'
    if nibble1 == 15: nibble1 = 'F'
    nibble2 = checksum % 16
    if nibble2 == 10: nibble2 = 'A'
    if nibble2 == 11: nibble2 = 'B'
    if nibble2 == 12: nibble2 = 'C'
    if nibble2 == 13: nibble2 = 'D'
    if nibble2 == 14: nibble2 = 'E'
    if nibble2 == 15: nibble2 = 'F'
    checksum = str(nibble1) + str(nibble2)
    if(checksum != ctrl): 
        print(checksum, ctrl)
        return [-2,0,0,0,0,0,0] 


    hour = float(UTC[0:2])
    minute = float(UTC[2:4])
    sec = float(UTC[4:])

    lat_dg = int(Lat[0:2])
    lat_min = float(Lat[2:])
    lat = lat_dg + lat_min/60
    if SN == 'S':
        lat = lat * -1
    
    lon_dg = int(Lon[0:3])
    lon_min = float(Lon[3:])
    lon = lon_dg + lon_min/60
    if WE == 'W':
        lon *= -1
    
    
    
    

    return [0,hour, minute, sec, lat, lon, height]

def parseLines(lines):
    output = []
    for line in lines:
        parsed = parse(line)
        if parsed[0] == 0:
            output.append(parsed)
    return output

def parseFile(filename):
    lines = open(filename).readlines()
    return parseLines(lines)

def parseBytes(filename):
    chars = eval(open(filename).read())
    string = ''
    for ch in chars:
        string += chr(ch)
    return parseLines(string.split('\n'))
        

#The code below generates Google Static map for the provided set of lines. If you want to use it get the Google API key; keep in mind that static maps is a paid service (cost of a single image is less than 1 grosz, but still you need to connect your card and stuff).
api_key = 'XXXXXXXXXXXXXXXXX'

def calculateCenter(values):
    total = 0
    for value in values:
        total += value
    return total/(1.0*len(values))

def generateStaticMap(filename, image_filename):
    with open(filename) as file:
        lines = file.readlines()
        lats = []
        lons = []
        markers = []
        for parsedLine in parseLines(lines):
            lats.append(parsedLine[-3]) 
            lons.append(parsedLine[-2]) 
        centerLat = calculateCenter(lats)
        centerLon = calculateCenter(lons)
        center = f'{centerLat},{centerLon}'        
        zoom = '13'
        size = '600x300'
        mtype = 'roadmap'
        markers = []
        for i, _ in enumerate(lats):
            markers.append(f'color:blue%7Clabel:{i}%7C{lats[i]}, {lons[i]}')
        request = f"https://maps.googleapis.com/maps/api/staticmap?center={center}&zoom={zoom}&size={size}&maptype={mtype}"
        for marker in markers:
            request += f'&markers={marker}'
        request += f'&key={api_key}'
        response = requests.get(request)

        with open(image_filename,'wb+') as ofile:    
            ofile.write(response.content)
          
def main():
    for position in     parseBytes('test_files/bytes.nmea'):
        print(position)
if __name__ == '__main__':
    main()


