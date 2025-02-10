-- Pobranie widoku samolotów
SELECT * FROM zarzadzanie_lotniskiem_v2.widok_samoloty;

-- Pobranie widoku załogi
SELECT * FROM zarzadzanie_lotniskiem_v2.widok_zaloga;

-- Pobranie załogi przypisanej do samolotów
SELECT * FROM zarzadzanie_lotniskiem_v2.widok_zaloga_na_samolot;

-- Pobranie linii lotniczych
SELECT * FROM zarzadzanie_lotniskiem_v2.widok_linie_lotnicze;

-- Pobranie liczby lotów na linię lotniczą
SELECT * FROM zarzadzanie_lotniskiem_v2.widok_loty_na_linie;

-- Pobranie terminali
SELECT * FROM zarzadzanie_lotniskiem_v2.widok_terminali;

-- Pobranie liczby lotów przypisanych do terminalu
SELECT * FROM zarzadzanie_lotniskiem_v2.widok_loty_na_terminal;

-- Pobranie szczegółowych danych lotów
SELECT 
    lot_id, numer_lotu, nazwa_linii, model_samolotu, terminal,
    poczatek, cel, czas_odlotu, czas_przylotu, liczba_rezerwacji, pojemnosc_samolotu
FROM zarzadzanie_lotniskiem_v2.widok_loty;

-- Pobranie danych użytkownika na podstawie ID
SELECT * 
FROM zarzadzanie_lotniskiem_v2.Uzytkownicy 
WHERE u_id = :uzytkownik_id;

-- Zmiana hasła użytkownika (przykład dynamicznego zapytania SQL)
UPDATE zarzadzanie_lotniskiem_v2.Uzytkownicy
SET haslo = :nowe_haslo
WHERE u_id = :uzytkownik_id;

-- Zmiana numeru telefonu użytkownika
UPDATE zarzadzanie_lotniskiem_v2.Uzytkownicy
SET telefon = :nowy_telefon
WHERE u_id = :uzytkownik_id;

-- Pobranie rezerwacji użytkownika
SELECT 
    r.rezerwacja_id,
    l.numer_lotu,
    lin.nazwa AS linia_lotnicza,
    sam.model AS model_samolotu,
    t.nazwa AS terminal,
    l.poczatek,
    l.cel,
    l.czas_odlotu,
    l.czas_przylotu,
    r.klasa_miejsca,
    r.status
FROM zarzadzanie_lotniskiem_v2.Rezerwacje r
JOIN zarzadzanie_lotniskiem_v2.Loty l ON r.lot_id = l.lot_id
JOIN zarzadzanie_lotniskiem_v2.LinieLotnicze lin ON l.linia_id = lin.linia_id
LEFT JOIN zarzadzanie_lotniskiem_v2.Terminale t ON l.terminal_id = t.terminal_id
LEFT JOIN zarzadzanie_lotniskiem_v2.Samoloty sam ON l.samolot_id = sam.samolot_id
WHERE r.u_id = :uzytkownik_id
ORDER BY l.czas_odlotu ASC;

-- Dodanie nowej rezerwacji
INSERT INTO zarzadzanie_lotniskiem_v2.Rezerwacje (u_id, lot_id, klasa_miejsca)
VALUES (:u_id, :lot_id, :klasa_miejsca);

-- Usunięcie rezerwacji
DELETE FROM zarzadzanie_lotniskiem_v2.Rezerwacje 
WHERE rezerwacja_id = :rezerwacja_id;

-- Dodanie nowego samolotu
INSERT INTO zarzadzanie_lotniskiem_v2.Samoloty (model, pojemnosc, linia_id)
VALUES (:model, :pojemnosc, :linia_id);

-- Usunięcie samolotu
DELETE FROM zarzadzanie_lotniskiem_v2.Samoloty 
WHERE samolot_id = :samolot_id;

-- Dodanie nowego członka załogi
INSERT INTO zarzadzanie_lotniskiem_v2.Zaloga (imie, nazwisko, rola, linia_id, samolot_id)
VALUES (:imie, :nazwisko, :rola, :linia_id, :samolot_id);

-- Usunięcie członka załogi
DELETE FROM zarzadzanie_lotniskiem_v2.Zaloga 
WHERE zaloga_id = :zaloga_id;

-- Dodanie nowej linii lotniczej
INSERT INTO zarzadzanie_lotniskiem_v2.LinieLotnicze (nazwa, kraj)
VALUES (:nazwa, :kraj);

-- Usunięcie linii lotniczej
DELETE FROM zarzadzanie_lotniskiem_v2.LinieLotnicze 
WHERE linia_id = :linia_id;

-- Dodanie nowego terminalu
INSERT INTO zarzadzanie_lotniskiem_v2.Terminale (nazwa, pojemnosc)
VALUES (:nazwa, :pojemnosc);

-- Usunięcie terminalu
DELETE FROM zarzadzanie_lotniskiem_v2.Terminale 
WHERE terminal_id = :terminal_id;

-- Dodanie nowego lotu
INSERT INTO zarzadzanie_lotniskiem_v2.Loty 
(numer_lotu, linia_id, samolot_id, terminal_id, poczatek, cel, czas_odlotu, czas_przylotu)
VALUES (:numer_lotu, :linia_id, :samolot_id, :terminal_id, :poczatek, :cel, :czas_odlotu, :czas_przylotu);

-- Usunięcie lotu
DELETE FROM zarzadzanie_lotniskiem_v2.Loty 
WHERE lot_id = :lot_id;

-- Pobranie wszystkich użytkowników
SELECT 
    u_id,
    imie,
    nazwisko,
    email,
    telefon,
    rola,
    data_rejestracji,
    liczba_rezerwacji
FROM zarzadzanie_lotniskiem_v2.widok_uzytkownicy
ORDER BY u_id ASC;

-- Usunięcie użytkownika
DELETE FROM zarzadzanie_lotniskiem_v2.Uzytkownicy 
WHERE u_id = :u_id;