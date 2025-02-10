<?php
session_start();
// Sprawdzenie, czy użytkownik jest zalogowany i ma uprawnienia administratora
if (!isset($_SESSION['logged_in']) || $_SESSION['role'] !== 'admin') {
    header("Location: auth.php");
    exit();
}
require_once 'functions.php';

// Obsługa żądań wysyłanych metodą POST (dodawanie i usuwanie samolotów oraz członków załogi)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['dodaj_samolot'])) {
        dodajSamolot($db, $_POST);
    } elseif (isset($_POST['dodaj_zaloge'])) {
        dodajZaloge($db, $_POST);
    } elseif (isset($_POST['usun_samolot'])) {
        usunSamolot($db, $_POST['samolot_id']);
    } elseif (isset($_POST['usun_zaloga'])) {
        usunZaloga($db, $_POST['zaloga_id']);
    }
    header("Location: flota.php");
    exit();
}

// Pobieranie danych do wyświetlenia w formularzach i tabelach
$linie = pobierzLinieLotnicze($db);
$samoloty = pobierzWidokSamoloty($db);
$zaloga = pobierzWidokZaloga($db);
$zalogaNaSamoloty = pobierzZalogeNaSamoloty($db);
?>

<!DOCTYPE html>
<html lang="pl">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portal Administratora - Flota</title>
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

    <h1>Portal Administratora - Flota</h1>
    <nav>
        <a href="loty.php" class="button">Loty</a>
        <a href="rezerwacje_loty.php" class="button">Rezerwacje</a>
        <a href="flota.php" class="button active">Flota</a>
        <a href="infrastruktura.php" class="button">Infrastruktura</a>
        <a href="uzytkownicy.php" class="button">Użytkownicy</a>
        <a href="klient.php" class="button">Portal Klienta</a>
        <a href="logout.php" class="button logout">Wyloguj</a>
    </nav>

    <div class="container">
        <div class="form-container">
            <form method="POST">
                <h2>Dodaj nowy samolot</h2>
                <label>Model: <input type="text" name="model" required></label>
                <label>Pojemność: <input type="number" name="pojemnosc" required></label>
                <label>Linia lotnicza:
                    <select name="linia_id" required>
                        <option value="">-- Wybierz linię lotniczą --</option>
                        <?php foreach ($linie as $linia): ?>
                            <option value="<?= $linia['linia_id'] ?>"><?= $linia['nazwa'] ?></option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <button type="submit" name="dodaj_samolot">Dodaj samolot</button>
            </form>

            <form method="POST">
                <h2>Dodaj członka załogi</h2>
                <label>Imię: <input type="text" name="imie" required></label>
                <label>Nazwisko: <input type="text" name="nazwisko" required></label>
                <label>Rola:
                    <select name="rola" required>
                        <option value="">-- Wybierz rolę --</option>
                        <option value="Kapitan">Kapitan</option>
                        <option value="Drugi Pilot">Drugi Pilot</option>
                        <option value="Obsługa Kabiny">Obsługa Kabiny</option>
                    </select>
                </label>
                <label>Linia lotnicza:
                    <select name="linia_id" id="linia_id" required>
                        <option value="">-- Wybierz linię lotniczą --</option>
                        <?php foreach ($linie as $linia): ?>
                            <option value="<?= $linia['linia_id'] ?>"><?= $linia['nazwa'] ?></option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <label>Samolot:
                    <select name="samolot_id" id="samolot_id">
                        <option value="">-- Wybierz samolot --</option>
                    </select>
                </label>
                <button type="submit" name="dodaj_zaloge">Dodaj członka załogi</button>
            </form>
        </div>

        <div class="tables-container">
            <div class="table-wrapper">
                <h2>Samoloty</h2>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Model</th>
                            <th>Pojemność</th>
                            <th>Linia Lotnicza</th>
                            <th>Liczba Załogi</th>
                            <th>Akcje</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($samoloty as $samolot): ?>
                            <tr>
                                <td><?= $samolot['samolot_id'] ?></td>
                                <td><?= $samolot['model'] ?></td>
                                <td><?= $samolot['pojemnosc'] ?></td>
                                <td><?= $samolot['nazwa_linii'] ?></td>
                                <td>
                                    <?php
                                    $liczbaZalogi = 0;
                                    foreach ($zalogaNaSamoloty as $zalogaSamolot) {
                                        if ($zalogaSamolot['samolot_id'] === $samolot['samolot_id']) {
                                            $liczbaZalogi = $zalogaSamolot['liczba_zalogi'];
                                            break;
                                        }
                                    }
                                    echo $liczbaZalogi;
                                    ?>
                                </td>
                                <td>
                                    <form method="POST">
                                        <input type="hidden" name="samolot_id" value="<?= $samolot['samolot_id'] ?>">
                                        <button type="submit" name="usun_samolot">Usuń</button>
                                    </form>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>

            <div class="table-wrapper">
                <h2>Załoga</h2>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Imię</th>
                            <th>Nazwisko</th>
                            <th>Rola</th>
                            <th>Linia Lotnicza</th>
                            <th>Samolot</th>
                            <th>Akcje</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($zaloga as $czlonek): ?>
                            <tr>
                                <td><?= $czlonek['zaloga_id'] ?></td>
                                <td><?= $czlonek['imie'] ?></td>
                                <td><?= $czlonek['nazwisko'] ?></td>
                                <td><?= $czlonek['rola'] ?></td>
                                <td><?= $czlonek['nazwa_linii'] ?></td>
                                <td><?= $czlonek['samolot_id'] ?: 'Nie przypisano' ?></td>
                                <td>
                                    <form method="POST">
                                        <input type="hidden" name="zaloga_id" value="<?= $czlonek['zaloga_id'] ?>">
                                        <button type="submit" name="usun_zaloga">Usuń</button>
                                    </form>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        document.getElementById('linia_id').addEventListener('change', function () {
            const liniaId = this.value;
            const samolotSelect = document.getElementById('samolot_id');

            if (liniaId) {
                fetch(`get_planes.php?linia_id=${liniaId}`)
                    .then(response => response.json())
                    .then(data => {
                        samolotSelect.innerHTML = '<option value="">-- Wybierz samolot --</option>';
                        data.forEach(samolot => {
                            const option = document.createElement('option');
                            option.value = samolot.samolot_id;
                            option.textContent = samolot.model;
                            samolotSelect.appendChild(option);
                        });
                    })
                    .catch(error => console.error('Błąd:', error));
            } else {
                samolotSelect.innerHTML = '<option value="">-- Wybierz samolot --</option>';
            }
        });
    </script>
</body>

</html>