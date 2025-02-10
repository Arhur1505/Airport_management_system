<?php
require 'functions.php';

// Sprawdzenie, czy żądanie zostało wysłane metodą POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Pobranie danych z formularza lub ustawienie ich na null, jeśli nie są przesłane
    $imie = $_POST['imie'] ?? null;
    $nazwisko = $_POST['nazwisko'] ?? null;
    $rola = $_POST['rola'] ?? null;
    $samolot_id = $_POST['samolot_id'] ?? null;

    // Walidacja - sprawdzenie, czy wszystkie wymagane pola zostały wypełnione
    if (!$imie || !$nazwisko || !$rola || !$samolot_id) {
        die("Wszystkie pola są wymagane.");
    }

    try {
        // Wywołanie funkcji dodającej nowego członka załogi do bazy danych
        dodajCzlonkaZalogi($db, $imie, $nazwisko, $rola, $samolot_id);
        echo "Członek załogi został dodany pomyślnie.";
    } catch (PDOException $e) {
        // Obsługa błędów bazy danych - wyświetlenie komunikatu o błędzie
        echo "Błąd bazy danych: " . $e->getMessage();
    }
}

/**
 * Dodaje nowego członka załogi do bazy danych.
 *
 * @param PDO $db Obiekt PDO do połączenia z bazą danych.
 * @param string $imie Imię członka załogi.
 * @param string $nazwisko Nazwisko członka załogi.
 * @param string $rola Rola członka załogi (np. pilot, stewardessa).
 * @param int $samolot_id ID samolotu, do którego przypisana jest załoga.
 * @return void
 */
function dodajCzlonkaZalogi($db, $imie, $nazwisko, $rola, $samolot_id)
{
    $query = $db->prepare("
        INSERT INTO zarzadzanie_lotniskiem_v2.Zaloga (imie, nazwisko, rola, samolot_id, linia_id)
        VALUES (:imie, :nazwisko, :rola, :samolot_id, 
        (SELECT linia_id FROM zarzadzanie_lotniskiem_v2.Samoloty WHERE samolot_id = :samolot_id))
    ");
    $query->bindParam(':imie', $imie);
    $query->bindParam(':nazwisko', $nazwisko);
    $query->bindParam(':rola', $rola);
    $query->bindParam(':samolot_id', $samolot_id);

    $query->execute();
}
