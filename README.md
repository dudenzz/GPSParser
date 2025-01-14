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

Pierwsza z metod przyjmuje jako argument jedną linię z urządzenia GPS. Wyjście tej metody to <kod_ramki, godzina, minuta, sekunda, długość geograficzna, szerokość geograficzna>. W przypadku kiedy szerokość geograficzna jest dodatnia oznacza ona szerokość północną, w przeciwnym wypadku południową. W przypadku kiedy długość geograficzna jest dodatnia oznacza ona długość wschodnią, w przeciwnm wypadku zachodnią. Jest to standardowa konwencja stosowana np. w Mapach Google. W przypadku, kiedy podana ramka nie jest ramką GGA, zwracana wartość kodu ramki wynosi -1, a w przypadku, gdy suma kontrolna jest niepoprawna, zwracana wartość kodu ramki to -2. W przypadku, gdy ramka jest niepełna, zwracany kod to -3. Jeżeli mamy do czynienia z prawidłową ramką GGA, kod ramki wynosi 0. 

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


 ## Python

 ### wykorzystanie 'minimalne'

 W katalogu src/python_nmea znajduje się plik nmea.py. Wewnątrz tego pliku znajdują się dwie metody parsujące oraz jedna generująca mapy z Google Static Maps. Wystarczy skopiować te metody i można ich używać w dowolnym miejscu. UWAGA! metoda generująca mapy wymaga pakietu requests (pip install requests).


 ### wykorzystanie jako pakiet

 1. W pierwszej kolejności powinno zostać utworzone środowisko wirtualne. Pakiet jest mały, ale na pewno nie musi być wykorzystywany we wszystkich projektach. Ten punkt jest opcjonalny, ale proponuję korzystać ze środowiska wirtualnego.

 2. Jeżeli ma być wykorzystywana metoda generowania map statycznych z Google w pliku src/python_nmea/nmea.py w linii 63 należy zmienić wartość klucza API z XXX.... na poprawny klucz do API google z dostępem do Google Static Maps API, jeżeli ta metoda nie będzie wkorzystywana, można ten krok pominąć.

 3. Należy przejść w terminalu do katalogu głównego repozytorium

 4. Należy zainstalować pakiet

     pip install -e .

 5. Od tego moment w środowisku pakiet parsera dostępnym jest pod nazwą python_nmea. Przykład wykorzystania:



       from python_nmea import nmea
       nmea.generateStaticMap('test_files/ryszard.nmea','test_images/ryszard.png')
       nmea.generateStaticMap('test_files/synthetic.nmea','test_images/synthetic.png')
       with open('test_files/synthetic.nmea') as file:
           for line in nmea.parseLines(file.readlines()):
               print(line)
       with open('test_files/ryszard.nmea') as file:
           for line in file:
               print(nmea.parse(line))
