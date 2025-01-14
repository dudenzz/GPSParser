#include "GPSPosition.h"
#include <list>
#include <vector>
#include <string>
#ifndef C_NMEA_PARSER
#define C_NMEA_PARSER

namespace nmea
{
    class NMEAParser
    {
    public:
        GPSPosition *parse(std::string line);
        GPSPosition *parse(char *line);
        std::list<GPSPosition *> parseLines(std::string *lines);
        char *generateControl(char *line);
        
    };
}

#endif // C_NMEA_PARSER