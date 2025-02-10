<?php
session_start();
// Sprawdzenie, czy użytkownik jest zalogowany oraz czy posiada odpowiednią rolę (klient lub admin)
if (!isset($_SESSION['logged_in']) || !in_array($_SESSION['role'], ['klient', 'admin'])) {
    header("Location: auth.php");
    exit();
}

require_once 'db.php';
require_once 'functions.php';

// Obsługa żądań wysłanych metodą POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['kup_bilet'])) {
        // Dodanie rezerwacji
        $lot_id = $_POST['lot_id'];
        $klasa_miejsca = $_POST['klasa_miejsca'];
        $uzytkownik_id = $_SESSION['user_id'];

        try {
            dodajRezerwacje($db, $uzytkownik_id, $lot_id, $klasa_miejsca);
            $success = "Rezerwacja została pomyślnie dodana.";
        } catch (PDOException $e) {
            $error = "Wystąpił błąd podczas rezerwacji: " . $e->getMessage();
        }
    } elseif (isset($_POST['usun_rezerwacje'])) {
        // Usunięcie istniejącej rezerwacji
        $rezerwacja_id = $_POST['rezerwacja_id'];

        try {
            usunRezerwacje($db, $rezerwacja_id);
            $success = "Rezerwacja została pomyślnie usunięta.";
        } catch (PDOException $e) {
            $error = "Wystąpił błąd podczas usuwania rezerwacji: " . $e->getMessage();
        }
    }

    header("Location: klient.php");
    exit();
}

// Pobranie danych o lotach do wyświetlenia w tabeli
$data = pobierzDaneLotow($db);
$loty = $data['loty'];

$rezerwacje = pobierzRezerwacjeUzytkownika($db, $_SESSION['user_id']);
?>
<!DOCTYPE html>
<html lang="pl">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portal Klienta - Loty</title>
    <link rel="stylesheet" href="css/style_3.css">
</head>

<body>
    <h1>Portal Klienta - Loty</h1>

    <nav>
        <a href="klient.php" class="button active">Loty</a>
        <a href="dane_klienta.php" class="button">Moje dane</a>
        <?php if ($_SESSION['role'] === 'admin'): ?>
            <a href="loty.php" class="button">Portal Administratora</a>
        <?php endif; ?>
        <a href="logout.php" class="button logout">Wyloguj</a>
    </nav>

    <div class="loty-content-container">
        <div class="loty-table-container">
            <h2>Lista lotów</h2>
            <?php if (isset($success)): ?>
                <p style="color: green;"> <?= $success ?> </p>
            <?php endif; ?>

            <?php if (isset($error)): ?>
                <p style="color: red;"> <?= $error ?> </p>
            <?php endif; ?>

            <table>
                <thead>
                    <tr>
                        <th>Numer lotu</th>
                        <th>Linia lotnicza</th>
                        <th>Samolot</th>
                        <th>Terminal</th>
                        <th>Początek</th>
                        <th>Cel</th>
                        <th>Odlot</th>
                        <th>Przylot</th>
                        <th>Rezerwacje</th>
                        <th>Klasa</th>
                        <th>Akcje</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($loty as $lot): ?>
                        <tr>
                            <td><?= htmlspecialchars($lot['numer_lotu']) ?></td>
                            <td><?= htmlspecialchars($lot['nazwa_linii']) ?></td>
                            <td><?= htmlspecialchars($lot['model_samolotu']) ?></td>
                            <td><?= htmlspecialchars($lot['terminal']) ?></td>
                            <td><?= htmlspecialchars($lot['poczatek']) ?></td>
                            <td><?= htmlspecialchars($lot['cel']) ?></td>
                            <td><?= htmlspecialchars($lot['czas_odlotu']) ?></td>
                            <td><?= htmlspecialchars($lot['czas_przylotu']) ?></td>
                            <td><?= htmlspecialchars($lot['liczba_rezerwacji']) ?>/<?= htmlspecialchars($lot['pojemnosc_samolotu']) ?>
                            </td>
                            <td>
                                <form method="POST" style="display: inline;">
                                    <select name="klasa_miejsca" required>
                                        <option value="Ekonomiczna">Ekonomiczna</option>
                                        <option value="Ekonomiczna Premium">Ekonomiczna Premium</option>
                                        <option value="Biznes">Biznes</option>
                                        <option value="Pierwsza">Pierwsza</option>
                                    </select>
                            </td>
                            <td>
                                <input type="hidden" name="lot_id" value="<?= $lot['lot_id'] ?>">
                                <button type="submit" name="kup_bilet" class="button-kup-bilet">Kup bilet</button>
                                </form>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>

        <div class="loty-table-container">
            <h2>Moje rezerwacje</h2>
            <table>
                <thead>
                    <tr>
                        <th>Numer lotu</th>
                        <th>Linia lotnicza</th>
                        <th>Samolot</th>
                        <th>Terminal</th>
                        <th>Początek</th>
                        <th>Cel</th>
                        <th>Odlot</th>
                        <th>Przylot</th>
                        <th>Klasa</th>
                        <th>Status</th>
                        <th>Akcje</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (!empty($rezerwacje)): ?>
                        <?php foreach ($rezerwacje as $rezerwacja): ?>
                            <tr>
                                <td><?= htmlspecialchars($rezerwacja['numer_lotu']) ?></td>
                                <td><?= htmlspecialchars($rezerwacja['linia_lotnicza']) ?></td>
                                <td><?= htmlspecialchars($rezerwacja['model_samolotu']) ?></td>
                                <td><?= htmlspecialchars($rezerwacja['terminal']) ?></td>
                                <td><?= htmlspecialchars($rezerwacja['poczatek']) ?></td>
                                <td><?= htmlspecialchars($rezerwacja['cel']) ?></td>
                                <td><?= htmlspecialchars($rezerwacja['czas_odlotu']) ?></td>
                                <td><?= htmlspecialchars($rezerwacja['czas_przylotu']) ?></td>
                                <td><?= htmlspecialchars($rezerwacja['klasa_miejsca']) ?></td>
                                <td><?= htmlspecialchars($rezerwacja['status']) ?></td>
                                <td>
                                    <form method="POST">
                                        <input type="hidden" name="rezerwacja_id" value="<?= $rezerwacja['rezerwacja_id'] ?>">
                                        <button type="submit" name="usun_rezerwacje" class="button-kup-bilet">Usuń</button>
                                    </form>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php else: ?>
                        <tr>
                            <td colspan="11">Brak rezerwacji.</td>
                        </tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</body>

</html>