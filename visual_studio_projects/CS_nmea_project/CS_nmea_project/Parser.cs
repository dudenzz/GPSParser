using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CS_nmea_project
{
    class Parser
    {
        public static Position parseLine(string line)
        {
            string[] tokens = line.Split(',');
            if(tokens.Length != 15) return new Position(Position.PositionType.WRONG_SIZE);
            if (tokens[0] != "$GPGGA") return new Position(Position.PositionType.WRONG_FRAME);
            int checksum = 0;
            for(int i = 0; i<line.Length; i++)
            {
                checksum = checksum ^ (byte)line[i];
            }
            int nibble1 = checksum / 16;
            int nibble2 = checksum % 16;
            string nibble1str = "";
            string nibble2str = "";
            if (nibble1 > 9)
            {
                if (nibble1 == 10) nibble1str = "A";
                if (nibble1 == 11) nibble1str = "B";
                if (nibble1 == 12) nibble1str = "C";
                if (nibble1 == 13) nibble1str = "D";
                if (nibble1 == 14) nibble1str = "E";
                if (nibble1 == 15) nibble1str = "F";
            }
            else nibble1str = nibble1.ToString();
            if (nibble2 > 9)
            {
                if (nibble2 == 10) nibble2str = "A";
                if (nibble2 == 11) nibble2str = "B";
                if (nibble2 == 12) nibble2str = "C";
                if (nibble2 == 13) nibble2str = "D";
                if (nibble2 == 14) nibble2str = "E";
                if (nibble2 == 15) nibble2str = "F";
            }
            else nibble2str = nibble2.ToString();
            string checksumStr = nibble1str + nibble2str;
            string checksumLine = tokens[14].Split('*') [1].Trim();
            if (checksumStr != checksumLine) return new Position(Position.PositionType.CHECKSUM_ERROR);


        }
    }
}
