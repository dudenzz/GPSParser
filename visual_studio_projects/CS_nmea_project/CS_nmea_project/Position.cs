using System;

class Position
{
    public enum PositionType
    {
        VALID,
        WRONG_FRAME,
        WRONG_SIZE,
        CHECKSUM_ERROR
    }
    public double Lat {  get; set; }
    public double Lon { get; set; }
    
    public double Height { get; set; }
    public DateTime Time { get; set; }
    public PositionType Type { get; set; }
    public Position(double lat, double lon, double height, DateTime time, PositionType type = PositionType.VALID)
    {
        Lat = lat;
        Lon = lon;
        Height = height;
        Time = time;
        Type = type;
    }

    public Position(PositionType type)
    {
        Lat = 0;
        Lon = 0;
        Height = 0;
        Time = DateTime.MinValue;
        this.Type = type;
    }
}

