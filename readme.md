# Dokumentacja projektu bazy danych

## Dostęp do aplikacji

Aplikacja jest dostępna pod adresem:  
[http://localhost:8080/~2jozwiak/auth.php](http://localhost:8080/~2jozwiak/auth.php)

### Dane logowania:

#### Konto administratora:

- **Email:** admin@admin
- **Hasło:** admin

#### Konto klienta:

- **Email:** klient@klient
- **Hasło:** klient

### Informacja o bazie danych:

Baza danych znajduje się na serwerze **Tembo** i wymaga odnawiania codziennie.  
Jeśli podczas korzystania z aplikacji pojawi się komunikat o braku możliwości połączenia z bazą danych, proszę o kontakt na **Teams**. Zazwyczaj odnawiam bazę codziennie.

---

## Struktura projektu

### Foldery i pliki:

1. **`BD_dokumentacja`**  
   Plik PDF zawierający pełną dokumentację projektu zgodnie z wymaganiami.

2. **`sql`**  
   Folder zawierający pliki SQL wykorzystywane w projekcie:

   - **`baza_backup.sql`**  
     Plik SQL generowany automatycznie za pomocą **DBeaver** (opcja `Backup`).  
     Służy jako kopia zapasowa bazy danych.
   - **`baza_ddl.sql`**  
     Plik SQL generowany automatycznie za pomocą programu **DBeaver** (opcja `Generate SQL`).  
     Zawiera pełny schemat bazy danych, w tym definicje tabel, kluczy głównych i obcych.
   - **`kwerendy.sql`**  
     Plik zawierający kwerendy SQL wykorzystywane w projekcie.
   - **`kod.sql`**  
     Plik z kodem SQL definiującym tabele w bazie danych.
   - **`widoki.sql`**  
     Plik zawierający definicje widoków.
   - **`wyzwalacze.sql`**  
     Plik zawierający kod wyzwalaczy (triggerów).

3. **`public_html`**  
   Folder zawierający pliki z kodem aplikacji webowej w PHP:
   - **`add_crew.php`**  
     Obsługuje dodawanie członków załogi do bazy danych.
   - **`auth.php`**  
     Strona logowania i rejestracji – obsługuje logowanie i autoryzację użytkowników.
   - **`dane_klienta.php`**  
     Strona dla klienta – wyświetla i zarządza danymi klientów.
   - **`db.php`**  
     Obsługuje połączenie z bazą danych.
   - **`flota.php`**  
     Strona administratora – zarządzanie flotą samolotów i załogą.
   - **`functions.php`**  
     Funkcje pomocnicze wykorzystywane w aplikacji.
   - **`get_planes.php`**  
     Pobiera informacje o dostępnych samolotach.
   - **`infrastruktura.php`**  
     Strona administratora – zarządzanie terminalami i liniami lotniczymi.
   - **`klient.php`**  
     Strona klienta – zarządzanie rezerwacjami i wyświetlanie lotów.
   - **`logout.php`**  
     Obsługuje wylogowanie użytkownika.
   - **`loty.php`**  
     Strona administratora – zarządzanie lotami.
   - **`rezerwacje_loty.php`**  
     Strona administratora – zarządzanie rezerwacjami lotów.
   - **`użytkownicy.php`**  
     Strona administratora – zarządzanie użytkownikami systemu (np. dodawanie i usuwanie kont).
   - **`css`**  
     Folder zawierający pliki stylów CSS używane w aplikacji.

---