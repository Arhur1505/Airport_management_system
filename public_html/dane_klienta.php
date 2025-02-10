<?php
session_start();
// Sprawdzenie, czy użytkownik jest zalogowany oraz czy posiada odpowiednią rolę (klient lub admin)
if (!isset($_SESSION['logged_in']) || !in_array($_SESSION['role'], ['klient', 'admin'])) {
    header("Location: auth.php");
    exit();
}

require_once 'db.php';
require_once 'functions.php';

// Pobranie ID użytkownika z sesji
$uzytkownik_id = $_SESSION['user_id'];
// Pobranie danych użytkownika z bazy danych na podstawie jego ID
$uzytkownik = pobierzDaneUzytkownika($db, $uzytkownik_id);

// Obsługa formularzy wysłanych metodą POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['zmien_haslo'])) {
        $aktualne_haslo = $_POST['aktualne_haslo'];
        $nowe_haslo = $_POST['nowe_haslo'];
        $potwierdz_haslo = $_POST['potwierdz_haslo'];

        // Walidacja danych w formularzu zmiany hasła
        if ($nowe_haslo !== $potwierdz_haslo) {
            $error = "Nowe hasło i potwierdzenie hasła muszą być takie same.";
        } elseif (!password_verify($aktualne_haslo, $uzytkownik['haslo'])) {
            $error = "Aktualne hasło jest nieprawidłowe.";
        } else {
            try {
                // Zmiana hasła w bazie danych
                zmienHaslo($db, $uzytkownik_id, $nowe_haslo);
                header("Location: dane_klienta.php?success=haslo");
                exit();
            } catch (PDOException $e) {
                $error = "Wystąpił błąd podczas zmiany hasła: " . $e->getMessage();
            }
        }
    }

    // Obsługa zmiany numeru telefonu
    if (isset($_POST['zmien_telefon'])) {
        $nowy_telefon = $_POST['nowy_telefon'];

        try {
            // Zmiana numeru telefonu w bazie danych
            zmienTelefon($db, $uzytkownik_id, $nowy_telefon);
            header("Location: dane_klienta.php?success=telefon");
            exit();
        } catch (PDOException $e) {
            $error = "Wystąpił błąd podczas zmiany numeru telefonu: " . $e->getMessage();
        }
    }
}

// Obsługa komunikatów sukcesu po zmianie hasła lub numeru telefonu
if (isset($_GET['success'])) {
    if ($_GET['success'] === 'haslo') {
        $success = "Hasło zostało pomyślnie zmienione.";
    } elseif ($_GET['success'] === 'telefon') {
        $success = "Numer telefonu został pomyślnie zaktualizowany.";
    }
}
?>

<!DOCTYPE html>
<html lang="pl">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portal Klienta - Dane Klienta</title>
    <link rel="stylesheet" href="css/style_3.css">
</head>

<body>
    <h1>Portal Klienta - Dane Klienta</h1>

    <nav>
        <a href="klient.php" class="button">Loty</a>
        <a href="dane_klienta.php" class="button active">Moje dane</a>
        <?php if ($_SESSION['role'] === 'admin'): ?>
            <a href="loty.php" class="button">Portal Administratora</a>
        <?php endif; ?>
        <a href="logout.php" class="button logout">Wyloguj</a>
    </nav>

    <div class="content-container">
        <div class="user-data-container">
            <h2>Twoje dane</h2>
            <p><strong>Imię:</strong> <?= htmlspecialchars($uzytkownik['imie']) ?></p>
            <p><strong>Nazwisko:</strong> <?= htmlspecialchars($uzytkownik['nazwisko']) ?></p>
            <p><strong>Email:</strong> <?= htmlspecialchars($uzytkownik['email']) ?></p>
            <p><strong>Telefon:</strong> <?= htmlspecialchars($uzytkownik['telefon']) ?></p>
        </div>

        <div class="form-container">
            <h2>Zmień hasło</h2>
            <?php if (isset($success) && $_GET['success'] === 'haslo'): ?>
                <p class="success-message"><?= htmlspecialchars($success) ?></p>
            <?php endif; ?>

            <?php if (isset($error)): ?>
                <p class="error-message"><?= htmlspecialchars($error) ?></p>
            <?php endif; ?>

            <form method="POST">
                <label for="aktualne_haslo">Aktualne hasło</label>
                <input type="password" name="aktualne_haslo" id="aktualne_haslo" required>

                <label for="nowe_haslo">Nowe hasło</label>
                <input type="password" name="nowe_haslo" id="nowe_haslo" required>

                <label for="potwierdz_haslo">Potwierdź nowe hasło</label>
                <input type="password" name="potwierdz_haslo" id="potwierdz_haslo" required>

                <button type="submit" name="zmien_haslo" class="button">Zmień hasło</button>
            </form>
        </div>

        <div class="form-container">
            <h2>Zmień numer telefonu</h2>
            <?php if (isset($success) && $_GET['success'] === 'telefon'): ?>
                <p class="success-message"><?= htmlspecialchars($success) ?></p>
            <?php endif; ?>

            <form method="POST">
                <label for="nowy_telefon">Nowy numer telefonu</label>
                <input type="text" name="nowy_telefon" id="nowy_telefon"
                    value="<?= htmlspecialchars($uzytkownik['telefon']) ?>" required>

                <button type="submit" name="zmien_telefon" class="button">Zmień numer telefonu</button>
            </form>
        </div>
    </div>
</body>

</html>