--WIDOKI

-- Widok przedstawiający szczegóły rezerwacji dla każdego lotu
CREATE OR REPLACE VIEW zarzadzanie_lotniskiem_v2.widok_rezerwacje_dla_lotu AS
SELECT 
    r.rezerwacja_id,
    u.imie,
    u.nazwisko,
    u.email,
    u.telefon,
    r.klasa_miejsca,
    r.status,
    r.lot_id
FROM zarzadzanie_lotniskiem_v2.Rezerwacje r
JOIN zarzadzanie_lotniskiem_v2.Uzytkownicy u ON r.u_id = u.u_id;

-- Widok przedstawiający wszystkich użytkowników oraz liczbę dokonanych przez nich rezerwacji
CREATE OR REPLACE VIEW zarzadzanie_lotniskiem_v2.widok_uzytkownicy AS
SELECT
    u.u_id,
    u.imie,
    u.nazwisko,
    u.email,
    u.telefon,
    u.rola,
    DATE(u.data_rejestracji) AS data_rejestracji,
    COALESCE((SELECT COUNT(*) FROM Rezerwacje r WHERE r.u_id = u.u_id), 0) AS liczba_rezerwacji
FROM Uzytkownicy u;

-- Widok przedstawiający szczegóły lotów, w tym liczbę rezerwacji przypisaną do każdego lotu
CREATE OR REPLACE VIEW zarzadzanie_lotniskiem_v2.widok_loty AS
SELECT 
    l.lot_id,
    l.numer_lotu,
    lin.nazwa AS nazwa_linii,
    sam.model AS model_samolotu,
    sam.pojemnosc AS pojemnosc_samolotu,
    (SELECT COUNT(*) 
     FROM zarzadzanie_lotniskiem_v2.Rezerwacje r 
     WHERE r.lot_id = l.lot_id) AS liczba_rezerwacji,
    l.poczatek,
    l.cel,
    l.czas_odlotu,
    l.czas_przylotu,
    t.nazwa AS terminal
FROM zarzadzanie_lotniskiem_v2.Loty l
JOIN zarzadzanie_lotniskiem_v2.LinieLotnicze lin ON l.linia_id = lin.linia_id
JOIN zarzadzanie_lotniskiem_v2.Samoloty sam ON l.samolot_id = sam.samolot_id
LEFT JOIN zarzadzanie_lotniskiem_v2.Terminale t ON l.terminal_id = t.terminal_id;

-- Widok przedstawiający liczbę lotów przypisanych do każdego terminalu
CREATE OR REPLACE VIEW widok_loty_na_terminal AS
SELECT 
    t.terminal_id,
    t.nazwa as nazwa_terminalu,
    COUNT(l.lot_id) AS liczba_lotow
FROM Terminale t
LEFT JOIN Loty l ON t.terminal_id = l.terminal_id
GROUP BY t.terminal_id, t.nazwa;

-- Widok przedstawiający szczegóły załogi, w tym ich przynależność do linii lotniczej
CREATE OR REPLACE VIEW widok_zaloga AS
SELECT 
    z.zaloga_id,
    z.imie,
    z.nazwisko,
    z.rola,
    l.nazwa AS nazwa_linii,
    z.samolot_id
FROM Zaloga z
JOIN LinieLotnicze l ON z.linia_id = l.linia_id;

-- Widok przedstawiający załogę przypisaną do każdego samolotu
CREATE OR REPLACE VIEW widok_zaloga_na_samolot AS
SELECT 
    s.samolot_id,
    s.model AS model_samolotu,
    COUNT(z.zaloga_id) AS liczba_zalogi
FROM Samoloty s
LEFT JOIN Zaloga z ON s.samolot_id = z.samolot_id
GROUP BY s.samolot_id, s.model;

-- Widok przedstawiający liczbę lotów przypisanych do każdej linii lotniczej
CREATE OR REPLACE VIEW widok_loty_na_linie AS
SELECT 
    lin.linia_id,
    lin.nazwa AS linia_lotnicza,
    COUNT(l.lot_id) AS liczba_lotow
FROM Loty l
JOIN LinieLotnicze lin ON l.linia_id = lin.linia_id
GROUP BY lin.linia_id, lin.nazwa;

-- Widok przedstawiający podstawowe dane o liniach lotniczych
CREATE OR REPLACE VIEW widok_linie_lotnicze AS
SELECT 
    linia_id,
    nazwa,
    kraj
FROM LinieLotnicze;

-- Widok przedstawiający podstawowe dane o terminalach
CREATE OR REPLACE VIEW widok_terminali AS
SELECT 
    terminal_id,
    nazwa,
    pojemnosc
FROM Terminale;

-- Widok przedstawiający szczegóły samolotów, w tym ich przynależność do linii lotniczych
CREATE OR REPLACE VIEW widok_samoloty AS
SELECT 
    s.samolot_id,
    s.model,
    s.pojemnosc,
    s.linia_id,
    l.nazwa AS nazwa_linii
FROM Samoloty s
JOIN LinieLotnicze l ON s.linia_id = l.linia_id;