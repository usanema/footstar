<tech-stack>
- **Frontend**: Flutter (Mobile + PWA)
- **Backend (Hybrid)**: Kotlin + Spring (Custom) AND Supabase (BaaS)
- **AI**: OpenRouter.ai
- **Hosting/DevOps**: DigitalOcean (Docker), Github Actions
</tech-stack>

## Krytyczna Analiza Stacku Technologicznego

Poniższa analiza weryfikuje zasadność proponowanego stacku w kontekście wymagań MVP aplikacji **FootStar**.

### 1. Czy technologia pozwoli nam szybko dostarczyć MVP?
**Odpowiedź: TAK, ale z ryzykiem opóźnień przez nadmiarowość.**

Użycie **Fluttera** to doskonały wybór – pozwala na jednoczesne dostarczenie aplikacji mobilnej i wersji webowej (PWA) z jednego kodu, co drastycznie skraca czas developmentu.
Użycie **Supabase** również przyspiesza prace (gotowa autentykacja, baza danych, API).

**Zagrożenie:** Proponowane połączenie "Kotlin + Spring" ORAZ "Supabase" jest potencjalnym wąskim gardłem. Supabase z założenia ma zastąpić backend. Budowanie równolegle customowego backendu w Springu wprowadza konieczność dublowania logiki, synchronizacji tokenów autoryzacyjnych i zarządzania infrastrukturą (Docker, VPS), co jest sprzeczne z ideą szybkiego MVP.

### 2. Czy rozwiązanie będzie skalowalne w miarę wzrostu projektu?
**Odpowiedź: TAK, bardzo skalowalne.**

- **Supabase** opiera się na PostgreSQL, który jest standardem branżowym w skalowalności.
- **Spring Boot** to rozwiązanie enterprise – obsłuży miliony użytkowników.
- **Problem:** W fazie MVP "zbyt duża skalowalność" (over-engineering) może zabić projekt kosztami i czasem.

### 3. Czy koszt utrzymania i rozwoju będzie akceptowalny?
**Odpowiedź: NIEKONIECZNIE.**

- **Supabase** oferuje hojny darmowy plan, co jest idealne dla MVP.
- **Spring + DigitalOcean**: Wymaga płatnego hostingu (Droplet) od pierwszego dnia, konfiguracji domeny, certyfikatów SSL, monitoringu i aktualizacji systemu operacyjnego.
- **Wniosek**: Utrzymanie dedykowanego serwera z Javą generuje stałe koszty (finansowe i czasowe - DevOps), których można uniknąć w modelu Serverless/BaaS.

### 4. Czy potrzebujemy aż tak złożonego rozwiązania?
**Odpowiedź: ZDECYDOWANIE NIE.**

Wymagania PRD dla MVP są proste:
- Rejestracja/Logowanie (Supabase Auth to ma).
- Baza danych grup/meczów (Supabase DB to ma).
- Algorytm dobierania składów (to jedyna "logika biznesowa").

Stawianie pełnego serwera Spring Boot tylko dla jednego algorytmu to "strzelanie z armaty do muchy".

### 5. Czy nie istnieje prostsze podejście, które spełni nasze wymagania?
**Odpowiedź: TAK - Architektura "Supabase-First".**

Zamiast hybrydy (Spring + Supabase), sugeruję:
1.  **Frontend**: Flutter (bez zmian).
2.  **Backend**: **Tylko Supabase**.
3.  **Logika (Algorytm)**: Zamiast Springa, użycie **Supabase Edge Functions** (TypeScript/Deno) LUB małej usługi (Cloud Function), która uruchamia się tylko na żądanie przeliczenia składów.
4.  **Hosting**: Vercel/Netlify dla wersji Web, Sklepy dla Mobile. Brak konieczności zarządzania VPS-em (DigitalOcean).

To podejście usuwa potrzebę konfiguracji Dockera, Springa, CI/CD dla backendu i obniża koszty początkowe do blisko 0 PLN.

### 6. Czy technologie pozwoli nam zadbać o odpowiednie bezpieczeństwo?
**Odpowiedź: TAK, pod warunkiem spójności.**

Supabase oferuje **Row Level Security (RLS)**, co pozwala na bardzo granularne zarządzanie dostępem bezpośrednio w bazie.
W modelu hybrydowym (Spring + Supabase) pojawia się ryzyko:
- Czy Spring ma łączyć się z bazą jako "admin" (omijając RLS)?
- Czy Spring ma weryfikować tokeny Supabase?
Rozdwojenie logiki bezpieczeństwa między RLS a kod Javy zwiększa powierzchnię ataku i ryzyko błędów konfiguracyjnych.

## Rekomendacja
Dla fazy MVP, **rekomenduję rezygnację z modułu "Kotlin + Spring" i hostingu Dockerowego**.
Zalecam pełne oparcie się o ekosystem **Supabase (Auth + DB + Edge Functions)**. Spring Boot można wprowadzić w fazie 2.0 (Post-MVP), jeśli logika biznesowa stanie się zbyt złożona dla funkcji serverless.