# Dokument wymagań produktu (PRD) - FootStar

## 1. Przegląd produktu
**FootStar** to aplikacja mobilna (Flutter) oraz webowa (PWA), której celem jest kompleksowe wsparcie amatorskich grup piłkarskich w organizacji meczów. System eliminuje chaos komunikacyjny związany z umawianiem spotkań, zbieraniem składu, wyborem boiska oraz rozliczaniem płatności. Dodatkowo wprowadza element grywalizacji poprzez system oceniania (ratingu), statystyki i automatyczne dobieranie zbalansowanych składów.

-   **Platforma**: Flutter (iOS/Android) + PWA (Web).
-   **Backend**: Supabase (PostgreSQL + Auth + Edge Functions).
-   **Baza danych/Auth**: Supabase.
-   **Główna wartość**: Zastąpienie chaotycznych wątków na Messengerze dedykowanym narzędziem typu "wszystko w jednym" dla organizatora i graczy.

## 2. Problem użytkownika
Obecnie amatorskie grupy piłkarskie nie posiadają dedykowanego narzędzia do zarządzania swoją aktywnością. Organizacja opiera się na rozproszonych kanałach:
-   **Komunikacja**: Grupy na Facebooku/Messengerze/WhatsAppie, gdzie ważne informacje giną w tłumie wiadomości (spam).
-   **Organizacja**: Trudność w ustaleniu kto gra, kto jest rezerwowy, kto zrezygnował w ostatniej chwili.
-   **Rozliczenia**: Brak transparentności w płatnościach – organizator musi ręcznie ścigać dłużników i prowadzić papierowe lub excelowe notatki.
-   **Jakość gry**: Nierówne składy psute przez brak obiektywnej oceny umiejętności graczy, co prowadzi do frustracji (jedna drużyna dominuje).

## 3. Wymagania funkcjonalne
System składa się z trzech głównych modułów: Zarządzania Grupą, Organizacji Meczu oraz Narzędzi Po-meczowych.

### 3.1. Użytkownik i Grupa
-   **Rejestracja/Logowanie**: Obsługa kont użytkowników (email/hasło lub social login via Supabase).
-   **Profil Gracza**: Imię, nazwisko (jawne), preferowana pozycja, lepsza noga.
-   **Samoocena**: Przy rejestracji gracz ocenia swoje umiejętności (suwaki 0-5) w kategoriach (np. szybkość, technika, kondycja). Może istnieć globalny limit punktów do rozdania (np. max 30).
-   **Zarządzanie Grupą**: Tworzenie grupy, zapraszanie użytkowników (link), rola Administratora (organizatora).

### 3.2. Organizacja Meczu
-   **Tworzenie wydarzenia**: Wybór boiska z predefiniowanej listy 5 orlików w Katowicach (adres, nawierzchnia, cena).
-   **Deklaracja obecności**: Statusy "Będę", "Nie będę", "Rezerwa".
-   **Lista rezerwowa**: Automatyczne wskakiwanie do składu głównego, gdy ktoś zrezygnuje (powiadomienie email).
-   **Obsługa Gości ("Widmo")**: Administrator może dodać gracza spoza systemu (imię + nazwisko), aby uzupełnić skład.
-   **Szatnia**: Moduł ogłoszeń one-way (od admina do grupy) dotyczący konkretnego meczu.
-   **Pogoda**: Automatyczne pobieranie prognozy pogody dla terminu i lokalizacji meczu (OpenMeteo API).

### 3.3. Algorytm i Rozgrywka
-   **Inteligentny podział składów**: Algorytm dzielący graczy na dwie równe drużyny.
    -   *Pierwszy mecz*: Na podstawie samooceny.
    -   *Kolejne mecze*: Ważony algorytm (50% Głosy graczy, 30% %Zwycięstw, 20% Średnia goli). Wagi konfigurowalne w bazie.
    -   Goście nie mają wpływu na historię ratingową.

### 3.4. Po Meczu (Post-Match)
-   **Wprowadzanie wyniku**: Administrator wprowadza wynik meczu i statystyki (kto strzelił gola). Czas na edycję: 24h.
-   **Głosowanie (Feedback 360)**: Każdy gracz po meczu ma do rozdysponowania **5 punktów** na wyróżnienie innych zawodników (plusy). Głosowanie anonimowe, aktywne przez 24h.
-   **Płatności ("Cyfrowy zeszyt")**: Organizator ręcznie odznacza, kto zapłacił (np. przyjmując BLIK). System nalicza opłatę każdemu, kto był na liście "Będę" na 24h przed meczem.
-   **Statystyki**: Tabela ligowa, ranking strzelców, tytuły MVP (wyliczane z głosów, goli i wyniku).

## 4. Granice produktu
### Wchodzące w zakres (MVP)
-   Aplikacja mobilna i PWA.
-   Rejestracja i logowanie.
-   Tworzenie jednej grupy i zarządzanie nią.
-   Cyfrowy zeszyt płatności (bez procesowania transakcji online).
-   Algorytm podziału na składy.
-   Podstawowe statystyki i historia meczów.
-   Powiadomienia email.

### Poza zakresem (OUT)
-   Płatności in-app (bramki płatnicze).
-   Czat w czasie rzeczywistym (grupowy/prywatny).
-   Reklamy.
-   Umawianie sparingów międzygrupowych.
-   Turnieje i ligi zewnętrzne.
-   Sklep piłkarski.
-   Rezerwacja boisk online (integracja z systemami orlików).
-   Newsy sportowe.

## 5. Historyjki użytkowników

### Uwierzytelnianie i Profil (Auth & Profile)

**US-001: Rejestracja użytkownika**
-   **Tytuł**: Jako nowy użytkownik chcę założyć konto, aby móc dołączyć do drużyny.
-   **Opis**: Użytkownik podaje email, hasło oraz dane podstawowe (imię, nazwisko). Musi również wypełnić profil piłkarski (samoocena).
-   **Kryteria akceptacji**:
    1.  Formularz wymaga unikalnego adresu email.
    2.  Użytkownik musi zdefiniować suwakami swoje umiejętności (np. szybkość, technika).
    3.  Po wysłaniu formularza tworzone jest konto w Supabase.
    4.  Użytkownik otrzymuje email potwierdzający (opcjonalnie w MVP).

**US-002: Logowanie**
-   **Tytuł**: Jako użytkownik chcę się zalogować, aby uzyskać dostęp do moich meczów.
-   **Opis**: Bezpieczne logowanie przy użyciu emaila i hasła.
-   **Kryteria akceptacji**:
    1.  System weryfikuje poprawność danych.
    2.  Po 3 nieudanych próbach następuje tymczasowa blokada (security best practice).
    3.  Opcja "Przypomnij hasło" wysyła link resetujący.

### Zarządzanie Grupą (Group Management)

**US-003: Tworzenie grupy**
-   **Tytuł**: Jako organizator chcę utworzyć grupę, aby zarządzać moim zespołem.
-   **Opis**: Użytkownik tworzy nową "przestrzeń" dla swojej drużyny, nadając jej nazwę.
-   **Kryteria akceptacji**:
    1.  Użytkownik podaje nazwę grupy.
    2.  Twórca automatycznie staje się Administratorem.
    3.  Grupa otrzymuje unikalny link/kod zaproszeniowy.

**US-004: Zapraszanie do grupy**
-   **Tytuł**: Jako organizator chcę zaprosić graczy, aby dołączyli do mojej drużyny.
-   **Opis**: Generowanie linku, który można wysłać na Messengerze/SMS.
-   **Kryteria akceptacji**:
    1.  Link jest ważny i kieruje do rejestracji/dołączenia do konkretnej grupy.
    2.  Po kliknięciu, nowy użytkownik jest przypisywany do grupy.
    3.  Opcjonalnie uzytkownik moze wyszukac grupe po nazwie i dolaczyc do niej.

### Organizacja Meczu (Match Organization)

**US-005: Utworzenie meczu**
-   **Tytuł**: Jako organizator chcę zaplanować mecz, wybierając boisko i czas.
-   **Opis**: Wybór orlika z listy predefiniowanych, ustawienie daty, godziny i ceny za osobę.
-   **Kryteria akceptacji**:
    1.  Administrator wybiera orlik z listy (adres i cena są wczytywane).
    2.  Możliwość ręcznej edycji ceny jednostkowej za mecz.
    3.  Mecz pojawia się na liście nadchodzących wydarzeń.

**US-006: Deklaracja obecności**
-   **Tytuł**: Jako gracz chcę potwierdzić udział w meczu, aby organizator wiedział, czy jest skład.
-   **Opis**: Użytkownik klika "Będę", "Nie będę" lub "Rezerwa".
-   **Kryteria akceptacji**:
    1.  Zmiana statusu na "Nie będę" zwalnia miejsce.
    2.  Jeśli lista główna jest pełna, użytkownik trafia na listę rezerwową.
    3.  Jeśli ktoś z listy głównej zrezygnuje, pierwsza osoba z rezerwowej wskakuje automatycznie (FIFO) i dostaje powiadomienie.

**US-007: Dodanie gracza gościnnego**
-   **Tytuł**: Jako organizator chcę dodać gracza spoza systemu, aby uzupełnić braki w składzie.
-   **Opis**: Ręczne dodanie "Gościa" (imię + nazwisko) do listy obecności.
-   **Kryteria akceptacji**:
    1. Gosc otrzymuje unikalny link zaproszeniowy od innego gracza na mecz 
    2. Gosc po wejsciu w link ma mozliwsc zalozenia konta, zalogowania lub nadania pseudonimu i potwierdzenia obecnosci
    3.  Gość zajmuje slot tak samo jak zarejestrowany gracz.
    4.  Gość nie musi mieć konta ani emaila.

### Rozgrywka i Algorytm (Gameplay)

**US-008: Generowanie składów**
-   **Tytuł**: Jako organizator chcę automatycznie podzielić graczy na równe zespoły, aby mecz był sprawiedliwy.
-   **Opis**: Uruchomienie algorytmu, który balansuje drużyny na podstawie ratingu.
-   **Kryteria akceptacji**:
    1.  Algorytm bierze pod uwagę wszystkich graczy ze statusem "Będę".
    2.  Suma ratingów drużyny A i B powinna być zbliżona.
    3.  Administrator może ręcznie przesunąć graczy po wygenerowaniu (override).

**US-009: Podgląd szczegółów meczu**
-   **Tytuł**: Jako gracz chcę widzieć gdzie i kiedy gram oraz jaka będzie pogoda.
-   **Opis**: Ekran szczegółów meczu z mapą, godziną i prognozą pogody.
-   **Kryteria akceptacji**:
    1.  Wyświetlanie adresu orlika i mapy.
    2.  Wyświetlanie ikony pogody i temperatury (pobrane z API).
    3.  Widoczna lista uczestników.

### Po Meczu (Post-Match)

**US-010: Wprowadzenie wyniku i goli**
-   **Tytuł**: Jako organizator chcę wpisać wynik meczu i strzelców, aby zaktualizować statystyki.
-   **Opis**: Formularz dostępny po godzinie zakończenia meczu.
-   **Kryteria akceptacji**:
    1.  Wpisanie liczby goli dla Drużyny A i Drużyny B.
    2.  Zawodnicy deklarują ile strzelili bramek.
    3.  Edycja wyniku i liczby bramek jest możliwa przez 24h po meczu.

**US-011: Głosowanie na graczy**
-   **Tytuł**: Jako gracz chcę wyróżnić najlepszych zawodników, przyznając im punkty.
-   **Opis**: Każdy ma 5 punktów do rozdania kolegom z boiska po meczu.
-   **Kryteria akceptacji**:
    1.  Głosowanie dostępne przez 24h po meczu.
    2.  Nie można głosować na siebie.
    3.  Można przyznać punkty kilku graczom (suma max 5).
    4.  Głosowanie jest anonimowe.

**US-012: Zarządzanie płatnościami**
-   **Tytuł**: Jako organizator chcę oznaczyć kto zapłacił, aby kontrolować budżet.
-   **Opis**: Lista graczy z checkboxem "Opłacono".
-   **Kryteria akceptacji**:
    1.  Widok salda meczu (ile zebrano vs ile kosztuje orlik).
    2.  Możliwość oznaczenia wpłaty gotówką/BLIKiem (poza systemem).
    3.  Gracze widzą swój status "Opłacono/Nieopłacono".

**US-013: Przeglądanie statystyk**
-   **Tytuł**: Jako gracz chcę widzieć ranking najlepszych strzelców i MVP, aby porównać się z innymi.
-   **Opis**: Tabela ligowa generowana na podstawie historii meczów.
-   **Kryteria akceptacji**:
    1.  Tabela sortowalna po: liczbie goli, liczbie tytułów MVP, średniej ocen.
    2.  Widoczny własny progres (zmiana ratingu).

**US-014: Edycja profilu**
-   **Tytuł**: Jako gracz chcę edytować swój profil, aby uzupełnić dane.
-   **Opis**: Formularz dostępny po zalogowaniu.
-   **Kryteria akceptacji**:
    1.  Możliwość zmiany imienia, nazwiska, numeru telefonu, zdjęcia profilowego.
    2.  Możliwość zmiany preferowanej nogi, pozycji, wzrostu, wagi.

## 6. Metryki sukcesu
Aby uznać MVP za sukces i przejść do dalszego rozwoju, produkt musi osiągnąć następujące wskaźniki w fazie pilotażowej:

1.  **Aktywacja**: Rejestracja minimum **1 pełnej drużyny** (min. 10-14 osób).
2.  **Retencja**: Rozegranie i pełne obsłużenie w systemie **3 meczów** w ciągu **30 dni**.
3.  **Zaangażowanie**: 80% użytkowników oddaje głosy po meczu.
4.  **Techniczne**: Brak błędów krytycznych uniemożliwiających podział składów lub zapisanie wyniku.
