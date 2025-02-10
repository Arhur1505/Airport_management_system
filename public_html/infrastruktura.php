<?php
session_start();

// Sprawdzenie, czy użytkownik jest zalogowany i ma uprawnienia administratora
if (!isset($_SESSION['logged_in']) || $_SESSION['role'] !== 'admin') {
    header("Location: auth.php");
    exit();
}

require_once 'functions.php';

// Obsługa żądań wysłanych metodą POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        if (isset($_POST['dodaj_linia'])) {
            dodajLiniaLotnicza($db, $_POST['nazwa'], $_POST['kraj']);
        } elseif (isset($_POST['usun_linia'])) {
            usunLiniaLotnicza($db, $_POST['linia_id']);
        } elseif (isset($_POST['dodaj_terminal'])) {
            dodajTerminal($db, $_POST['nazwa_terminalu'], $_POST['pojemnosc']);
        } elseif (isset($_POST['usun_terminal'])) {
            usunTerminal($db, $_POST['terminal_id']);
        }
        header("Location: infrastruktura.php");
        exit;
    } catch (Exception $e) {
        $_SESSION['error'] = $e->getMessage();
    }
}

// Pobranie danych do wyświetlenia w tabelach
$linie = pobierzLinieLotnicze($db);
$lotyNaLinie = pobierzLotyNaLinie($db);
$terminale = pobierzTerminale($db);
$lotyNaTerminal = pobierzLotyNaTerminal($db);
?>

<!DOCTYPE html>
<html lang="pl">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portal Administratora - Infrastruktura</title>
    <link rel="stylesheet" href="css/style_2.css">
</head>

<body>
    <?php if (isset($_SESSION['error'])): ?>
        <div id="error-modal"
            style="position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background-color: #f8d7da; color: #721c24; padding: 20px; border: 2px solid #f5c6cb; border-radius: 8px; box-shadow: 0 8px 12px rgba(0, 0, 0, 0.2); text-align: center; width: 300px; font-family: Arial, sans-serif; font-size: 16px; z-index: 9999;">
            <strong>⚠️ Wystąpił błąd:</strong><br>
            <?= htmlspecialchars($_SESSION['error']) ?>
            <button onclick="closeError()"
                style="margin-top: 15px; padding: 8px 15px; background-color: #721c24; color: #fff; border: none; border-radius: 5px; cursor: pointer; font-size: 14px;">Zamknij</button>
        </div>
        <script>
            function closeError() {
                document.getElementById('error-modal').style.display = 'none';
            }
        </script>
        <?php unset($_SESSION['error']); ?>
    <?php endif; ?>

    <h1>Portal Administratora - Infrastruktura</h1>

    <nav>
        <a href="loty.php" class="button">Loty</a>
        <a href="rezerwacje_loty.php" class="button">Rezerwacje</a>
        <a href="flota.php" class="button">Flota</a>
        <a href="infrastruktura.php" class="button active">Infrastruktura</a>
        <a href="uzytkownicy.php" class="button">Użytkownicy</a>
        <a href="klient.php" class="button">Portal Klienta</a>
        <a href="logout.php" class="button logout">Wyloguj</a>
    </nav>

    <div class="container">
        <div class="form-container">
            <form method="POST">
                <h2>Dodaj nową linię lotniczą</h2>
                <label>Nazwa linii lotniczej: <input type="text" name="nazwa" required></label>
                <label>Kraj: <input type="text" name="kraj" required></label>
                <button type="submit" name="dodaj_linia">Dodaj linię lotniczą</button>
            </form>

            <form method="POST">
                <h2>Dodaj nowy terminal</h2>
                <label>Nazwa terminalu: <input type="text" name="nazwa_terminalu" required></label>
                <label>Pojemność: <input type="number" name="pojemnosc" required></label>
                <button type="submit" name="dodaj_terminal">Dodaj terminal</button>
            </form>
        </div>

        <div class="tables-container">
            <div class="table-wrapper">
                <h2>Linie Lotnicze</h2>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nazwa</th>
                            <th>Kraj</th>
                            <th>Liczba lotów</th>
                            <th>Akcje</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($linie as $linia): ?>
                            <tr>
                                <td><?= $linia['linia_id'] ?></td>
                                <td><?= $linia['nazwa'] ?></td>
                                <td><?= $linia['kraj'] ?></td>
                                <td>
                                    <?php
                                    $liczbaLotow = 0;
                                    foreach ($lotyNaLinie as $loty) {
                                        if ((int) $loty['linia_id'] === (int) $linia['linia_id']) {
                                            $liczbaLotow = $loty['liczba_lotow'];
                                            break;
                                        }
                                    }
                                    echo $liczbaLotow;
                                    ?>
                                </td>
                                <td>
                                    <form method="POST">
                                        <input type="hidden" name="linia_id" value="<?= $linia['linia_id'] ?>">
                                        <button type="submit" name="usun_linia">Usuń</button>
                                    </form>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>

            <div class="table-wrapper">
                <h2>Terminale</h2>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nazwa</th>
                            <th>Pojemność</th>
                            <th>Liczba lotów</th>
                            <th>Akcje</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($terminale as $terminal): ?>
                            <tr>
                                <td><?= $terminal['terminal_id'] ?></td>
                                <td><?= $terminal['nazwa'] ?></td>
                                <td><?= $terminal['pojemnosc'] ?></td>
                                <td>
                                    <?php
                                    $liczbaLotow = 0;
                                    foreach ($lotyNaTerminal as $loty) {
                                        if ((int) $loty['terminal_id'] === (int) $terminal['terminal_id']) {
                                            $liczbaLotow = $loty['liczba_lotow'];
                                            break;
                                        }
                                    }
                                    echo $liczbaLotow;
                                    ?>
                                </td>
                                <td>
                                    <form method="POST">
                                        <input type="hidden" name="terminal_id" value="<?= $terminal['terminal_id'] ?>">
                                        <button type="submit" name="usun_terminal">Usuń</button>
                                    </form>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>

</html>