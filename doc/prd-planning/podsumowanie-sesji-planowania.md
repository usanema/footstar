<conversation_summary>
<decisions>
1. **Platforma Technologiczna**: Aplikacja Flutter działająca jako PWA (Web) oraz Mobile. Backend: Java/Kotlin + Spring. Baza danych i Autoryzacja: Supabase.
2. **Definicja MVP Boisk**: Predefiniowana lista 5 orlików (Katowice) z informacjami (adres, nawierzchnia, mapa, cena). Rezerwacja odbywa się poza systemem (telefonicznie).
3. **Komunikacja**: Moduł "Szatnia" jako tablica ogłoszeń (komunikaty one-way od organizatora) wspierana powiadomieniami e-mail. Brak czatu w czasie rzeczywistym.
4. **Płatności**: Model "cyfrowego zeszytu". Organizator manualnie odznacza wpłaty BLIK. Zasada: płaci każdy, kto nie zrezygnował na 24h przed meczem.
5. **System Ocen i Algorytm**:
   - Pierwszy mecz: Podział na podstawie samooceny (suwaki 0-5 dla cech np. szybkość, technika).
   - Kolejne mecze: Algorytm ważący: 50% Głosy graczy, 30% %Zwycięstw, 20% Średnia goli. Wagi konfigurowalne w bazie danych.
   - Głosowanie: Anonimowe, okno 24h po meczu.
6. **Obsługa Gości**: Generowanie linku przez zapraszającego.Link otwiera gość i wypełnia pole gościa ( imie i nazwisko oraz numer ) lub się loguje ( jezeli ma konto) lub zaklada konto. Goście nie mają prawa głosu w ratingu i nie maja wglądu do historii.
7. **Mechanika Meczu**:
   - Czas trwania definiowany per wydarzenie.
   - Lista rezerwowa: Automatyczne wskoczenie do składu po rezygnacji kogoś z listy głównej (+powiadomienie e-mail).
   - Edycja wyniku: Możliwa przez 24h przez Administratora.
8. **Statystyki MVP**: Wynik meczu, Gole, Tytuł MVP (wyliczany matematycznie: głosy -> gole -> rating).
9. **Kryteria Sukcesu**: Rejestracja 1 drużyny i zamknięcie 3 meczów w ciągu 30 dni.
10. **Dane Profilowe**: Wymagane imię i nazwisko (widoczne dla grupy) oraz parametry piłkarskie (pozycja, noga).
</decisions>

<matched_recommendations>
1. **Model PWA**: Przyjęto rekomendację startu jako PWA, aby uniknąć barier sklepów z aplikacjami na początku.
2. **Automatyzacja Pogody**: Zaakceptowano użycie darmowego API (np. OpenMeteo) zamiast ręcznego wpisywania.
3. **Konta Gości ("Widmo")**: Przyjęto rekomendację, by to organizator zarządzał gośćmi, zamiast wymuszać na nich rejestrację.
4. **Lista Rezerwowa**: Zaakceptowano automatyzację przesunięć z listy rezerwowej.
5. **Jawność Ratingu**: Zdecydowano się na upublicznienie wskaźnika umiejętności dla grywalizacji.
</matched_recommendations>

<prd_planning_summary>
Sesja planowania pozwoliła na szczegółowe zdefiniowanie zakresu MVP (Minimum Viable Product).
**Główne wymagania funkcjonalne**:
- **Zarządzanie Grupą**: Tworzenie profili graczy (rozbudowane atrybuty fizyczne i techniczne), jedna rola Administratora.
- **Organizacja Meczu**: Wybór boiska z predefiniowanej listy, ustalanie składu (dostępność), automatyczny podział na drużyny (algorytm), obsługa listy rezerwowej.
- **Asystent Meczu**: "Szatnia" do ogłoszeń, automatyczna prognoza pogody.
- **Po Meczu**: Wprowadzanie wyniku, głosowanie na graczy (feedback 360), wyliczanie statystyk i rankingu.
- **Chierarchia poziomów**: Aplikacja -> Grupa-> Wydarzenie(mecz) 
**Kluczowe ścieżki użytkownika**:
1. *Onboarding*: Otrzymanie linku lub wejśce na stronę -> Rejestracja z samooceną -> Dołączenie do meczu lub Dołączenie do grupy 
2. *Organizator*: Utworzenie meczu -> Zaproszenie gości (jeśli brakuje składu) -> Zatwierdzenie składu -> Po meczu: Wpisanie wyniku i odznaczenie płatności.
3. *Gracz*: Deklaracja obecności -> Otrzymanie powiadomienia o składzie -> Gra -> Głosowanie na innych -> Sprawdzenie nowego Ratingu.
4. *Glosowanie*: po meczu zawodnik dostaje do rozdysponowania 5 pkt na innych zawodników

**Mierzalne wskaźniki**: Zdefiniowano jasne kryterium aktywacji (3 mecze w 30 dni dla nowej grupy).
</prd_planning_summary>

<unresolved_issues>
1. **Limit punktów samooceny**: Użytkownik zasugerował potencjalny limit sumaryczny (np. max 30 pkt do rozdania na wszystkie cechy), aby uniknąć profili "wszystko na max". Należy to ostatecznie potwierdzić przy pisaniu specyfikacji formularza rejestracji.
2. **Szczegóły API Pogodowego**: Należy wybrać konkretnego dostawcę API w fazie implementacji.
3. **Konfiguracja Wag**: Wagi algorytmu mają być w bazie danych, ale interfejs do ich zmiany (dla super-admina czy dla ownera grupy?) nie został precyzyjnie określony (założenie: konfigurowalne globalnie lub przez db-admina w MVP).
</unresolved_issues>
</conversation_summary>