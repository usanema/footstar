
    1. Gracz kazdej z umiejetnosci bedzie mógł przydzielić od 0 do 5 punktow. Zastanawiam się czy moznaby ograniczyc ilosc punktów np. max 30 pkt do rozdysponowania.
    Prowadzenie pilki, bronienie na bramce, drybling, 
    szybkosc, wytrzymalosc, obrona, atak, taktyka, 
    kluczowe podania, strategia, gra głową itp. Na podstawie tego będzie mógł przydzielić odpowiednią ilość punktów kazdej z tych umiejetnosci.   


    2. Zgodnie z rekomendacją integrujemy API pogodowe.


    3. Tak, automatycznie – pierwszy z rezerwy wskakuje do składu i otrzymuje powiadomienie e-mail.

    4.  W MVP – Nie. Gość zakładając konto zaczyna z czystą kartą. 
    Gość takze nie ma mozliwosc oceny innych graczy oraz otrzymac punktow od innych graczy. 


    5. Jesli chodzi o backend to zastanawiam się na Java/Kotlin + Spring ( w tym potrafię programować ) oraz Autoryzacja w Supabase Auth. 
    Baza danych takze w supabase.

    6. Usunmy te opcje. Niech to bedzie poza MVP. Jest to skomplikowany mechanizm, zeby okreslac czy jezeli ktos wypisze sie dzien wczesniej 
    i nie ma nikogo na rezerwie, to czy ta osoba ma placic. Zostawmy to na pozniej. 

    7. Osobowe : Imię, Nazwisko, Pseudonim,Miejscowość, Ulubiony Gracz, Ulubiony Zespół, Wzrost, Waga, Wiek - Rocznik ( trzy ostatnie nie sa wymagane, opcjonalne )
    Rating : Prowadzenie pilki, bronienie na bramce, drybling, 
    szybkosc, wytrzymalosc, obrona, atak, taktyka. Mozna by jeszcze dodac max 3. 
    Pozycja : Ulubiona Pozycja ( atak, obrona, pomoc, bramkarz ), Strona ( lewy, srodek, prawy), Noga wiodoca ( L/P/Obie )

    8. Definiowany per wydarzenie (np. 60/90/120 min) przy tworzeniu meczu.

    9.  W MVP – Tylko jeden Właściciel (Owner).

    10. Tak, w grupie zamkniętej Imię + Nazwisko (lub Inicjał) buduje zaufanie. 

    