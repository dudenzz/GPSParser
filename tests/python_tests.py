from python_nmea import nmea

# nmea.generateStaticMap('test_files/ryszard.nmea','test_images/ryszard.png')
# nmea.generateStaticMap('test_files/synthetic.nmea','test_images/synthetic.png')
with open('test_files/synthetic.nmea') as file:
    for line in nmea.parseLines(file.readlines()):
        print(line)

with open('test_files/ryszard.nmea') as file:
    for line in file:
        print(nmea.parse(line))