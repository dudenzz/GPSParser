# GPSParser
NMEA parser for the GPS module

To repozytorium kodu przechowuje parser protokołu NMEA napisany w następujących językach programowania: 

 - Python (przetestowany w wersji 3.11.7)
 - C++ (skompilowany za pomocą g++ 13.2.0)
 - C# (skompilowany za pomocą Visual Studio 2022 z domyślnym kompilatorem)
 - Java
 - JavaScript
 - Ruby
 - Perl

Interfejs parsera realizuje dwie metody

    parse(line) : <int, int, double, double, double>
    parseLines(lines) : List<double, double>

Pierwsza z metod przyjmuje jako argument jedną linię z urządzenia GPS. Wyjście tej metody to <godzina, minuta, sekunda, długość geograficzna, szerokość geograficzna>. W przypadku kiedy szerokość geograficzna jest dodatnia oznacza ona szerokość północną, w przeciwnym wypadku południową. W przypadku kiedy długość geograficzna jest dodatnia oznacza ona długość wschodnią, w przeciwnm wypadku zachodnią.

![image](https://github.com/user-attachments/assets/5a14a7e4-39dc-4b7b-a2ae-4ae3c2c230ec)

