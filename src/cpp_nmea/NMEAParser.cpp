#include "NMEAParser.h"
#include <cstring>
#include <iostream>
namespace nmea
{
    GPSPosition *NMEAParser::parse(std::string line)
    {
        std::vector<char> line_vec(line.size() + 1);
        memcpy(&line_vec.front(), line.c_str(), line.size() + 1);
        return parse(line_vec.data());
    }
    std::list<GPSPosition *> NMEAParser::parseLines(std::string *lines)
    {
        std::list<GPSPosition *> result;
        return result;
    }

    char *NMEAParser::generateControl(char *line)
    {
        char *ctrl = new char[2];
        char full_control = 0;
        int length = strlen(line);
        for (int i = 1; i <= length - 4; i++)
        {
            full_control = full_control ^ line[i];
        }
        char nibble1 = (char)full_control / 16;
        char nibble2 = full_control % 16;
        if (nibble1 == 0)
            ctrl[0] = '0';
        if (nibble1 == 1)
            ctrl[0] = '1';
        if (nibble1 == 2)
            ctrl[0] = '2';
        if (nibble1 == 3)
            ctrl[0] = '3';
        if (nibble1 == 4)
            ctrl[0] = '4';
        if (nibble1 == 5)
            ctrl[0] = '5';
        if (nibble1 == 6)
            ctrl[0] = '6';
        if (nibble1 == 7)
            ctrl[0] = '7';
        if (nibble1 == 8)
            ctrl[0] = '8';
        if (nibble1 == 9)
            ctrl[0] = '9';
        if (nibble1 == 10)
            ctrl[0] = 'A';
        if (nibble1 == 11)
            ctrl[0] = 'B';
        if (nibble1 == 12)
            ctrl[0] = 'C';
        if (nibble1 == 13)
            ctrl[0] = 'D';
        if (nibble1 == 14)
            ctrl[0] = 'E';
        if (nibble1 == 15)
            ctrl[0] = 'F';
        if (nibble2 == 0)
            ctrl[1] = '0';
        if (nibble2 == 1)
            ctrl[1] = '1';
        if (nibble2 == 2)
            ctrl[1] = '2';
        if (nibble2 == 3)
            ctrl[1] = '3';
        if (nibble2 == 4)
            ctrl[1] = '4';
        if (nibble2 == 5)
            ctrl[1] = '5';
        if (nibble2 == 6)
            ctrl[1] = '6';
        if (nibble2 == 7)
            ctrl[1] = '7';
        if (nibble2 == 8)
            ctrl[1] = '8';
        if (nibble2 == 9)
            ctrl[1] = '9';
        if (nibble2 == 10)
            ctrl[1] = 'A';
        if (nibble2 == 11)
            ctrl[1] = 'B';
        if (nibble2 == 12)
            ctrl[1] = 'C';
        if (nibble2 == 13)
            ctrl[1] = 'D';
        if (nibble2 == 14)
            ctrl[1] = 'E';
        if (nibble2 == 15)
            ctrl[1] = 'F';
        return ctrl;
    }
    GPSPosition *NMEAParser::parse(char *line)
    {
        int length = strlen(line);
        char **tokens = new char *[16];
        char *currentToken = new char[20];
        int currentPosition = 0;
        int currentTokenId = 0;
        char *control = generateControl(line);
        for (int i = 0; i < length; i++)
        {
            if(line[i] == ',')
            {
                char* newToken = new char[currentPosition + 1];
                strcpy(newToken,currentToken);
                newToken[currentPosition+1] = 0;
                tokens[currentTokenId] = newToken;
                currentTokenId = currentTokenId + 1;
                currentPosition = 0;
                currentToken = new char[20];

            }
            else
            {
                currentToken[currentPosition] = line[i];
                currentPosition = currentPosition + 1;
            }
        }
        int hour = (tokens[1][0] - '0')*10 + (tokens[1][1] - '0');
        std::cout << tokens[1][0] - '0';
        char* minute_str = new char[2];
        minute_str[0] = tokens[1][2];
        minute_str[0] = tokens[1][3];
        char* second_str = new char[9];
        second_str[0] = tokens[1][4];
        second_str[0] = tokens[1][5];
        second_str[0] = tokens[1][6];
        second_str[0] = tokens[1][7];
        second_str[0] = tokens[1][8];
        second_str[0] = tokens[1][9];
        int minute = atoi(minute_str);
        double second = atof(second_str);


        
        return new GPSPosition(hour,minute,second,0.0,0.0);
    }
}