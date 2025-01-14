#ifndef C_GPSPOSITION
#define C_GPSPOSITION
namespace nmea {
    class GPSPosition {
        public:
            int error_code;
            int hour;
            int minute;
            double second;
            double longtitude;
            double latitude;
            GPSPosition(int hour, int minute, double second, double longtitude, double latitude);
            GPSPosition(int error_code);
            GPSPosition();
            GPSPosition(GPSPosition& instance);
    };
}
#endif //C_GPSPOSITION