<?php
require_once 'db.php';

/**
 * Pobiera listę samolotów z widoku `widok_samoloty`.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @return array Tablica asocjacyjna zawierająca dane samolotów.
 */
function pobierzWidokSamoloty($db)
{
    $query = "SELECT * FROM zarzadzanie_lotniskiem_v2.widok_samoloty";
    return $db->query($query)->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Pobiera listę załóg z widoku `widok_zaloga`.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @return array Tablica asocjacyjna zawierająca dane załóg.
 */
function pobierzWidokZaloga($db)
{
    $query = "SELECT * FROM zarzadzanie_lotniskiem_v2.widok_zaloga";
    return $db->query($query)->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Pobiera dane załóg przypisanych do poszczególnych samolotów.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @return array Tablica asocjacyjna zawierająca dane załóg przypisanych do samolotów.
 */
function pobierzZalogeNaSamoloty($db)
{
    $query = "SELECT * FROM zarzadzanie_lotniskiem_v2.widok_zaloga_na_samolot";
    $stmt = $db->prepare($query);
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Pobiera listę linii lotniczych z widoku `widok_linie_lotnicze`.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @return array Tablica asocjacyjna zawierająca dane linii lotniczych.
 */
function pobierzLinieLotnicze($db)
{
    $query = "SELECT * FROM zarzadzanie_lotniskiem_v2.widok_linie_lotnicze";
    return $db->query($query)->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Pobiera dane lotów przypisanych do poszczególnych linii lotniczych.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @return array Tablica asocjacyjna z danymi lotów przypisanych do linii lotniczych.
 */
function pobierzLotyNaLinie($db)
{
    $query = "SELECT * FROM zarzadzanie_lotniskiem_v2.widok_loty_na_linie";
    return $db->query($query)->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Pobiera listę terminali z widoku `widok_terminali`.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @return array Tablica asocjacyjna zawierająca dane terminali.
 */
function pobierzTerminale($db)
{
    $query = "SELECT * FROM zarzadzanie_lotniskiem_v2.widok_terminali";
    return $db->query($query)->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Pobiera dane lotów przypisanych do poszczególnych terminali.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @return array Tablica asocjacyjna zawierająca dane lotów przypisanych do terminali.
 */
function pobierzLotyNaTerminal($db)
{
    $query = "SELECT * FROM zarzadzanie_lotniskiem_v2.widok_loty_na_terminal";
    return $db->query($query)->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Pobiera szczegółowe dane dotyczące lotów, linii lotniczych, samolotów i terminali.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @return array Tablica asocjacyjna z kluczami: `loty`, `linie`, `samoloty`, `terminale`.
 */
function pobierzDaneLotow($db)
{
    $lotyQuery = "
        SELECT 
            lot_id, numer_lotu, nazwa_linii, model_samolotu, terminal,
            poczatek, cel, czas_odlotu, czas_przylotu, liczba_rezerwacji, pojemnosc_samolotu
        FROM zarzadzanie_lotniskiem_v2.widok_loty
    ";
    $loty = $db->query($lotyQuery)->fetchAll(PDO::FETCH_ASSOC);

    $linie = $db->query("SELECT * FROM zarzadzanie_lotniskiem_v2.widok_linie_lotnicze")->fetchAll(PDO::FETCH_ASSOC);
    $samoloty = $db->query("SELECT * FROM zarzadzanie_lotniskiem_v2.widok_samoloty")->fetchAll(PDO::FETCH_ASSOC);
    $terminale = $db->query("SELECT * FROM zarzadzanie_lotniskiem_v2.widok_terminali")->fetchAll(PDO::FETCH_ASSOC);

    return [
        'loty' => $loty,
        'linie' => $linie,
        'samoloty' => $samoloty,
        'terminale' => $terminale,
    ];
}

/**
 * Pobiera dane użytkownika na podstawie jego ID.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param int $uzytkownik_id ID użytkownika.
 * @return array|null Tablica asocjacyjna z danymi użytkownika lub null, jeśli użytkownik nie istnieje.
 */
function pobierzDaneUzytkownika($db, $uzytkownik_id)
{
    $stmt = $db->prepare("SELECT * FROM zarzadzanie_lotniskiem_v2.Uzytkownicy WHERE u_id = :uzytkownik_id");
    $stmt->bindParam(':uzytkownik_id', $uzytkownik_id, PDO::PARAM_INT);
    $stmt->execute();
    return $stmt->fetch(PDO::FETCH_ASSOC);
}

/**
 * Zmienia hasło użytkownika.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param int $uzytkownik_id ID użytkownika.
 * @param string $nowe_haslo Nowe hasło do ustawienia.
 * @return void
 */
function zmienHaslo($db, $uzytkownik_id, $nowe_haslo)
{
    $hashed_password = password_hash($nowe_haslo, PASSWORD_DEFAULT);

    $stmt = $db->prepare("
        UPDATE zarzadzanie_lotniskiem_v2.Uzytkownicy
        SET haslo = :nowe_haslo
        WHERE u_id = :uzytkownik_id
    ");
    $stmt->bindParam(':nowe_haslo', $hashed_password);
    $stmt->bindParam(':uzytkownik_id', $uzytkownik_id);
    $stmt->execute();
}

/**
 * Zmienia numer telefonu użytkownika.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param int $uzytkownik_id ID użytkownika.
 * @param string $nowy_telefon Nowy numer telefonu do ustawienia.
 * @return void
 */
function zmienTelefon($db, $uzytkownik_id, $nowy_telefon)
{
    $stmt = $db->prepare("
        UPDATE zarzadzanie_lotniskiem_v2.Uzytkownicy
        SET telefon = :nowy_telefon
        WHERE u_id = :uzytkownik_id
    ");
    $stmt->bindParam(':nowy_telefon', $nowy_telefon);
    $stmt->bindParam(':uzytkownik_id', $uzytkownik_id);
    $stmt->execute();
}

/**
 * Pobiera rezerwacje użytkownika na podstawie jego ID.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param int $uzytkownik_id ID użytkownika.
 * @return array Tablica asocjacyjna zawierająca dane rezerwacji użytkownika.
 */
function pobierzRezerwacjeUzytkownika($db, $uzytkownik_id)
{
    $query = "
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
    ";

    $stmt = $db->prepare($query);
    $stmt->bindParam(':uzytkownik_id', $uzytkownik_id, PDO::PARAM_INT);
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Dodaje rezerwację dla użytkownika na określony lot.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param int $uzytkownik_id ID użytkownika.
 * @param int $lot_id ID lotu.
 * @param string $klasa_miejsca Klasa miejsca (np. ekonomiczna, biznesowa).
 * @return void
 */
function dodajRezerwacje($db, $uzytkownik_id, $lot_id, $klasa_miejsca)
{
    $stmt = $db->prepare("
        INSERT INTO zarzadzanie_lotniskiem_v2.Rezerwacje (u_id, lot_id, klasa_miejsca)
        VALUES (?, ?, ?)
    ");
    $stmt->execute([$uzytkownik_id, $lot_id, $klasa_miejsca]);
}

/**
 * Usuwa rezerwację na podstawie jej ID.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param int $rezerwacja_id ID rezerwacji.
 * @return void
 */
function usunRezerwacje($db, $rezerwacja_id)
{
    $stmt = $db->prepare("
        DELETE FROM zarzadzanie_lotniskiem_v2.Rezerwacje 
        WHERE rezerwacja_id = :rezerwacja_id
    ");
    $stmt->bindParam(':rezerwacja_id', $rezerwacja_id, PDO::PARAM_INT);
    $stmt->execute();
}

/**
 * Pobiera wszystkie loty w widoku `widok_loty`.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @return array Tablica asocjacyjna zawierająca dane lotów.
 */
function pobierzWszystkieLotyWidok($db)
{
    $query = "
        SELECT
            l.lot_id,
            l.numer_lotu,
            l.czas_odlotu,
            lin.nazwa AS linia_lotnicza,
            l.poczatek,
            l.cel
        FROM zarzadzanie_lotniskiem_v2.Loty l
        JOIN zarzadzanie_lotniskiem_v2.LinieLotnicze lin ON l.linia_id = lin.linia_id
        ORDER BY l.czas_odlotu
    ";
    $stmt = $db->prepare($query);
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Pobiera rezerwacje dla danego lotu z widoku `widok_rezerwacje_dla_lotu`.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param int $lot_id ID lotu.
 * @return array Tablica asocjacyjna z danymi rezerwacji dla danego lotu.
 */
function pobierzRezerwacjeDlaLotuWidok($db, $lot_id)
{
    $query = "
        SELECT 
            rezerwacja_id, 
            imie, 
            nazwisko, 
            email, 
            telefon, 
            klasa_miejsca, 
            status
        FROM zarzadzanie_lotniskiem_v2.widok_rezerwacje_dla_lotu
        WHERE lot_id = :lot_id
    ";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':lot_id', $lot_id, PDO::PARAM_INT);
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Dodaje nowy samolot do bazy danych.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param array $dane Tablica zawierająca dane samolotu (model, pojemność, linia_id).
 * @return void
 */
function dodajSamolot($db, $dane)
{
    try {
        $stmt = $db->prepare("INSERT INTO zarzadzanie_lotniskiem_v2.Samoloty (model, pojemnosc, linia_id) VALUES (?, ?, ?)");
        $stmt->execute([$dane['model'], $dane['pojemnosc'], $dane['linia_id']]);
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'Pojemność samolotu musi być liczbą dodatnią') !== false) {
            $_SESSION['error'] = "Wprowadź pojemność samolotu jako liczbę dodatnią";
        } else {
            $_SESSION['error'] = "Wystąpił błąd podczas dodawania samolotu";
        }
    }
}

/**
 * Usuwa samolot na podstawie jego ID.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param int $samolot_id ID samolotu.
 * @return void
 */
function usunSamolot($db, $samolot_id)
{
    $stmt = $db->prepare("DELETE FROM zarzadzanie_lotniskiem_v2.Samoloty WHERE samolot_id = ?");
    $stmt->execute([$samolot_id]);
}

/**
 * Dodaje nowego członka załogi do bazy danych.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param array $dane Tablica zawierająca dane załogi (imię, nazwisko, rola, linia_id, samolot_id).
 * @return void
 */
function dodajZaloge($db, $dane)
{
    try {
        $stmt = $db->prepare("INSERT INTO zarzadzanie_lotniskiem_v2.Zaloga (imie, nazwisko, rola, linia_id, samolot_id) VALUES (?, ?, ?, ?, ?)");
        $stmt->execute([
            $dane['imie'],
            $dane['nazwisko'],
            $dane['rola'],
            $dane['linia_id'],
            $dane['samolot_id'] ?: null
        ]);
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'Imię') !== false) {
            $_SESSION['error'] = "Imię członka załogi zawiera niedozwolone znaki";
        } elseif (strpos($e->getMessage(), 'Nazwisko') !== false) {
            $_SESSION['error'] = "Nazwisko członka załogi zawiera niedozwolone znaki";
        } else {
            $_SESSION['error'] = "Wystąpił błąd podczas dodawania członka załogi";
        }
    }
}

/**
 * Usuwa członka załogi na podstawie jego ID.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param int $zaloga_id ID członka załogi.
 * @return void
 */
function usunZaloga($db, $zaloga_id)
{
    $stmt = $db->prepare("DELETE FROM zarzadzanie_lotniskiem_v2.Zaloga WHERE zaloga_id = ?");
    $stmt->execute([$zaloga_id]);
}

/**
 * Dodaje nową linię lotniczą do bazy danych.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param string $nazwa Nazwa linii lotniczej.
 * @param string $kraj Kraj linii lotniczej.
 * @return void
 */
function dodajLiniaLotnicza($db, $nazwa, $kraj)
{
    try {
        $stmt = $db->prepare("INSERT INTO zarzadzanie_lotniskiem_v2.LinieLotnicze (nazwa, kraj) VALUES (?, ?)");
        $stmt->execute([$nazwa, $kraj]);
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'Niepoprawny format kraju') !== false) {
            $_SESSION['error'] = "Wprowadź poprawny format kraju (tylko litery).";
        } elseif (strpos($e->getMessage(), 'Linia lotnicza o nazwie') !== false) {
            $_SESSION['error'] = "Linia lotnicza o tej nazwie już istnieje.";
        } else {
            $_SESSION['error'] = "Wystąpił błąd podczas dodawania linii lotniczej.";
        }
    }
}

/**
 * Usuwa linię lotniczą na podstawie jej ID.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param int $linia_id ID linii lotniczej.
 * @return void
 */
function usunLiniaLotnicza($db, $linia_id)
{
    $stmt = $db->prepare("DELETE FROM zarzadzanie_lotniskiem_v2.LinieLotnicze WHERE linia_id = ?");
    $stmt->execute([$linia_id]);
}

/**
 * Dodaje nowy terminal do bazy danych.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param string $nazwa_terminalu Nazwa terminalu.
 * @param int $pojemnosc Pojemność terminalu.
 * @return void
 */
function dodajTerminal($db, $nazwa_terminalu, $pojemnosc)
{
    try {
        $stmt = $db->prepare("INSERT INTO zarzadzanie_lotniskiem_v2.Terminale (nazwa, pojemnosc) VALUES (?, ?)");
        $stmt->execute([$nazwa_terminalu, $pojemnosc]);
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'Pojemność terminalu musi być liczbą dodatnią') !== false) {
            $_SESSION['error'] = "Wprowadź pojemność terminalu jako liczbę dodatnią";
        } elseif (strpos($e->getMessage(), 'Terminal o nazwie') !== false) {
            $_SESSION['error'] = "Terminal o tej nazwie już istnieje";
        } else {
            $_SESSION['error'] = "Wystąpił błąd podczas dodawania terminalu";
        }
    }
}

/**
 * Usuwa terminal na podstawie jego ID.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param int $terminal_id ID terminalu.
 * @return void
 */
function usunTerminal($db, $terminal_id)
{
    $stmt = $db->prepare("DELETE FROM zarzadzanie_lotniskiem_v2.Terminale WHERE terminal_id = ?");
    $stmt->execute([$terminal_id]);
}

/**
 * Dodaje nowy lot do bazy danych.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param array $data Tablica zawierająca dane lotu:
 *                    - `numer_lotu`: string, unikalny numer lotu.
 *                    - `linia_id`: int, ID linii lotniczej.
 *                    - `samolot_id`: int, ID samolotu.
 *                    - `terminal_id`: int, ID terminalu.
 *                    - `poczatek`: string, miejsce początkowe.
 *                    - `cel`: string, miejsce docelowe.
 *                    - `czas_odlotu`: string, data i godzina odlotu (format: YYYY-MM-DD HH:MM:SS).
 *                    - `czas_przylotu`: string, data i godzina przylotu (format: YYYY-MM-DD HH:MM:SS).
 * @return void
 */
function dodajLot($db, $data)
{
    try {
        $stmt = $db->prepare("
            INSERT INTO zarzadzanie_lotniskiem_v2.Loty 
            (numer_lotu, linia_id, samolot_id, terminal_id, poczatek, cel, czas_odlotu, czas_przylotu)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([
            $data['numer_lotu'],
            $data['linia_id'],
            $data['samolot_id'],
            $data['terminal_id'],
            $data['poczatek'],
            $data['cel'],
            $data['czas_odlotu'],
            $data['czas_przylotu']
        ]);
    } catch (PDOException $e) {
        $errorMessage = $e->getMessage();

        if (strpos($errorMessage, 'unique constraint') !== false) {
            $_SESSION['error'] = "Numer lotu musi być unikalny. Wprowadź inny numer.";
        } elseif (strpos($errorMessage, 'Czas przylotu musi być późniejszy') !== false) {
            $_SESSION['error'] = "Czas przylotu musi być późniejszy niż czas odlotu.";
        } elseif (strpos($errorMessage, 'Początek i cel lotu') !== false) {
            $_SESSION['error'] = "Początek i cel lotu nie mogą być takie same.";
        } elseif (strpos($errorMessage, 'Samolot jest już przypisany') !== false) {
            $_SESSION['error'] = "Samolot jest już przypisany do innego lotu w tym czasie.";
        } elseif (strpos($errorMessage, 'Kapitan') !== false) {
            $_SESSION['error'] = "Samolot musi mieć przypisanego Kapitana.";
        } elseif (strpos($errorMessage, 'Drugi Pilot') !== false) {
            $_SESSION['error'] = "Samolot musi mieć przypisanego Drugiego Pilota.";
        } elseif (strpos($errorMessage, 'Obsługa Kabiny') !== false) {
            $_SESSION['error'] = "Samolot musi mieć przynajmniej jednego członka Obsługi Kabiny.";
        } else {
            $_SESSION['error'] = "Wystąpił błąd podczas dodawania lotu: " . $errorMessage;
        }
    }
}

/**
 * Usuwa lot na podstawie jego ID.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param int $lotId ID lotu.
 * @return void
 */
function usunLot($db, $lotId)
{
    $stmt = $db->prepare("DELETE FROM zarzadzanie_lotniskiem_v2.Loty WHERE lot_id = ?");
    $stmt->execute([$lotId]);
}

/**
 * Pobiera listę wszystkich użytkowników z widoku `widok_uzytkownicy`.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @return array Tablica asocjacyjna zawierająca dane użytkowników.
 */
function pobierzWszystkichUzytkownikowWidok($db)
{
    $query = "
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
        ORDER BY u_id ASC
    ";
    return $db->query($query)->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Usuwa użytkownika na podstawie jego ID.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param int $u_id ID użytkownika.
 * @return void
 */
function usunUzytkownika($db, $u_id)
{
    $stmt = $db->prepare("
        DELETE FROM zarzadzanie_lotniskiem_v2.Uzytkownicy 
        WHERE u_id = :u_id
    ");
    $stmt->bindParam(':u_id', $u_id, PDO::PARAM_INT);
    $stmt->execute();
}
?>