#include "../src/cpp_nmea/GPSPosition.h"
#include "../src/cpp_nmea/NMEAParser.h"
#include <iostream>
#include <cstring>
int main() {
    nmea::GPSPosition* position = new nmea::GPSPosition(1);
    nmea::NMEAParser parser;
    char* input = "$GPGGA,091955.873,5231.227,N,01323.859,E,1,12,1.0,0.0,M,0.0,M,,*66";
    int size;
    // for(int i = 0; i<size; i++)
    // {
    //     std::cout << tokens[i] << 'a';
    // }
    char* ctrl = parser.generateControl(input);
    std::cout << ctrl[0] << ctrl[1] << std::endl;
    auto result = parser.parse(input);
    std::cout << result->minute;
}
