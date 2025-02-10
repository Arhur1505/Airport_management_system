<?php
// Łańcuch połączenia z bazą danych PostgreSQL
$connectionString = "postgresql://postgres:hnut9LZ8bElVcLom@aurally-heartfelt-longspur.data-1.euc1.tembo.io:5432/postgres";

$url = parse_url($connectionString);

// Wydobycie poszczególnych elementów połączenia
$host = $url["host"];
$port = $url["port"];
$user = $url["user"];
$password = $url["pass"];
$dbname = ltrim($url["path"], "/");

// Przygotowanie połączenia z bazą danych w trybie PDO
try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $db = new PDO($dsn, $user, $password);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Błąd połączenia z bazą danych: " . $e->getMessage());
}
?>