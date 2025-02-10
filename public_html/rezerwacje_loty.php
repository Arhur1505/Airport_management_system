<?php
session_start();
if (!isset($_SESSION['logged_in']) || $_SESSION['role'] !== 'admin') {
    header("Location: auth.php");
    exit();
}

// Połączenie z bazą i wczytanie funkcji pomocniczych
require_once 'db.php';
require_once 'functions.php';

// Zmienna na komunikat sukcesu/błędu
$success = null;
$error = null;

// Obsługa usuwania rezerwacji
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['usun_rezerwacje'])) {
    $rezerwacja_id = $_POST['rezerwacja_id'];
    $lot_id = $_POST['lot_id'] ?? null;

    try {
        usunRezerwacje($db, $rezerwacja_id);
        header("Location: rezerwacje_loty.php?lot_id=$lot_id&msg=deleted");
        exit();
    } catch (PDOException $e) {
        $error = "Wystąpił błąd podczas usuwania rezerwacji: " . $e->getMessage();
    }
}

// Pobranie wszystkich lotów do selecta
$loty = pobierzWszystkieLotyWidok($db);
$rezerwacje = [];

// Obsługa pokazywania listy rezerwacji (GET)
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['lot_id'])) {
    $lot_id = $_GET['lot_id'];
    $rezerwacje = pobierzRezerwacjeDlaLotuWidok($db, $lot_id);

    if (isset($_GET['msg']) && $_GET['msg'] === 'deleted') {
        $success = "Rezerwacja została pomyślnie usunięta.";
    }
}
?>

<!DOCTYPE html>
<html lang="pl">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portal Administratora - Rezerwacje dla lotu</title>
    <link rel="stylesheet" href="css/style_4.css">
</head>

<body>
    <h1>Portal Administratora - Rezerwacje dla lotów</h1>

    <nav>
        <a href="loty.php" class="button">Loty</a>
        <a href="rezerwacje_loty.php" class="button active">Rezerwacje</a>
        <a href="flota.php" class="button">Flota</a>
        <a href="infrastruktura.php" class="button">Infrastruktura</a>
        <a href="uzytkownicy.php" class="button">Użytkownicy</a>
        <a href="klient.php" class="button">Portal Klienta</a>
        <a href="logout.php" class="button logout">Wyloguj</a>
    </nav>

    <div class="content-container">
        <div class="form-container">
            <h2>Wybierz lot</h2>
            <form method="GET" action="rezerwacje_loty.php">
                <label for="lot_id">Numer lotu:</label>
                <select name="lot_id" id="lot_id" required>
                    <option value="" disabled selected>Wybierz lot</option>
                    <?php foreach ($loty as $lot): ?>
                        <option value="<?= htmlspecialchars($lot['lot_id']) ?>" <?= (isset($_GET['lot_id']) && $_GET['lot_id'] == $lot['lot_id']) ? 'selected' : '' ?>>
                            <?= htmlspecialchars($lot['numer_lotu']) ?>
                            - <?= htmlspecialchars($lot['czas_odlotu']) ?>
                            - <?= htmlspecialchars($lot['linia_lotnicza']) ?>
                            (<?= htmlspecialchars($lot['poczatek']) ?> → <?= htmlspecialchars($lot['cel']) ?>)
                        </option>
                    <?php endforeach; ?>
                </select>
                <button type="submit" class="button">Pokaż rezerwacje</button>
            </form>
        </div>

        <div class="form-container">
            <h2>Lista rezerwacji</h2>

            <?php if ($success): ?>
                <p style="color: green;"><?= $success ?></p>
            <?php endif; ?>

            <?php if ($error): ?>
                <p style="color: red;"><?= $error ?></p>
            <?php endif; ?>

            <?php if (!empty($rezerwacje)): ?>
                <table>
                    <thead>
                        <tr>
                            <th>Numer rezerwacji</th>
                            <th>Imię</th>
                            <th>Nazwisko</th>
                            <th>Email</th>
                            <th>Telefon</th>
                            <th>Klasa</th>
                            <th>Status</th>
                            <th>Akcje</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($rezerwacje as $rezerwacja): ?>
                            <tr>
                                <td><?= htmlspecialchars($rezerwacja['rezerwacja_id']) ?></td>
                                <td><?= htmlspecialchars($rezerwacja['imie']) ?></td>
                                <td><?= htmlspecialchars($rezerwacja['nazwisko']) ?></td>
                                <td><?= htmlspecialchars($rezerwacja['email']) ?></td>
                                <td><?= htmlspecialchars($rezerwacja['telefon']) ?></td>
                                <td><?= htmlspecialchars($rezerwacja['klasa_miejsca']) ?></td>
                                <td><?= htmlspecialchars($rezerwacja['status']) ?></td>
                                <td>
                                    <form method="POST" style="display:inline;">
                                        <input type="hidden" name="rezerwacja_id"
                                            value="<?= htmlspecialchars($rezerwacja['rezerwacja_id']) ?>">
                                        <input type="hidden" name="lot_id"
                                            value="<?= htmlspecialchars($_GET['lot_id'] ?? '') ?>">
                                        <button type="submit" name="usun_rezerwacje" class="button-danger">Usuń</button>
                                    </form>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            <?php else: ?>
                <p>Brak rezerwacji dla wybranego lotu.</p>
            <?php endif; ?>
        </div>
    </div>
</body>

</html>