# GPSParser
NMEA parser for the GPS module

To repozytorium kodu przechowuje parser protokołu NMEA napisany w następujących językach programowania: 

 - Python (przetestowany w wersji 3.11.7)
 - C++ (skompilowany za pomocą g++ 13.2.0)
 - C# (skompilowany za pomocą Visual Studio 2022 z domyślnym kompilatorem)
 - Java
 - JavaScript

Interfejs parsera realizuje dwie metody

    parse(line) : <int, int, int, double, double, double>
    parseLines(lines) : List<int, int, int, double, double, double>

Pierwsza z metod przyjmuje jako argument jedną linię z urządzenia GPS. Wyjście tej metody to <kod_ramki, godzina, minuta, sekunda, długość geograficzna, szerokość geograficzna>. W przypadku kiedy szerokość geograficzna jest dodatnia oznacza ona szerokość północną, w przeciwnym wypadku południową. W przypadku kiedy długość geograficzna jest dodatnia oznacza ona długość wschodnią, w przeciwnm wypadku zachodnią. Jest to standardowa konwencja stosowana np. w Mapach Google. W przypadku, kiedy podana ramka nie jest ramką GGA, zwracana wartość kodu ramki wynosi -1, a w przypadku, gdy suma kontrolna jest niepoprawna, zwracana wartość kodu ramki to -2. Jeżeli mamy do czynienia z prawidłową ramką GGA, kod ramki wynosi 0. 

![image](https://github.com/user-attachments/assets/5a14a7e4-39dc-4b7b-a2ae-4ae3c2c230ec)


W implementacjach w językach C++, C# i Java, wyniki przechowywane są w sdedykowanej strukturze GPSPosition.

W języku python dane zwracane są w postaci krotki (ponumerowanego zbioru).

W języku JavaScript używany jest obiekt o następującej strukturze (przykładowy JSON)
    
    {
      code : 0,
      hour : 17,
      minute : 40,
      second : 40.23 ,
      lon : 46,2756 ,
      lat : 42,3311
    }

Druga z metod aplikuje do każdej z linii metodę parsującą - linie poprawne załączane są do wyniku działania tej funkcji. Funkcja zwraca listę opisanych wyżej elementów.


