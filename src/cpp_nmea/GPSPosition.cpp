#include "GPSPosition.h"

namespace nmea {
    GPSPosition::GPSPosition(int error_code) : error_code(error_code) {
        longtitude = 0.0;
        latitude = 0.0;
        second = 0.0;
        minute = 0;
        hour = 0;
    }

    GPSPosition::GPSPosition(int hour, int minute, double second, double latitude, double longtitude):
        longtitude(longtitude),
        latitude(latitude),
        second(second),
        minute(minute),
        hour(hour)
    {
        error_code = 0;
    }

    GPSPosition::GPSPosition()
    {
        error_code = -4;
        longtitude = 0.0;
        latitude = 0.0;
        second = 0.0;
        minute = 0;
        hour = 0;
    }

    GPSPosition::GPSPosition(GPSPosition& gpsPosition)
    {
        error_code = gpsPosition.error_code;
        longtitude = gpsPosition.longtitude;
        latitude = gpsPosition.latitude;
        second = gpsPosition.second;
        minute = gpsPosition.minute;
        hour = gpsPosition.hour;
        
    }
}