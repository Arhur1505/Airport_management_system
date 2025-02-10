<?php
require_once 'functions.php';

// Sprawdzenie, czy parametr `linia_id` został przekazany w zapytaniu GET
if (isset($_GET['linia_id'])) {
    $liniaId = intval($_GET['linia_id']);
    $samoloty = pobierzSamolotyDlaLinii($db, $liniaId);
    echo json_encode($samoloty);
}

/**
 * Pobiera listę samolotów dla danej linii lotniczej.
 *
 * @param PDO $db Obiekt PDO do komunikacji z bazą danych.
 * @param int $liniaId ID linii lotniczej.
 * @return array Lista samolotów w formacie tablicy asocjacyjnej (zawiera ID samolotu i jego model).
 */
function pobierzSamolotyDlaLinii($db, $liniaId)
{
    $query = "SELECT samolot_id, model FROM zarzadzanie_lotniskiem_v2.Samoloty WHERE linia_id = ?";
    $stmt = $db->prepare($query);
    $stmt->execute([$liniaId]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}