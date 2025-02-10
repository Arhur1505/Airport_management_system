<?php
session_start();

// Sprawdzenie, czy użytkownik jest zalogowany i ma uprawnienia administratora
if (!isset($_SESSION['logged_in']) || $_SESSION['role'] !== 'admin') {
    header("Location: auth.php");
    exit();
}
require_once 'db.php';
require_once 'functions.php';

// Obsługa formularza: dodanie lub usunięcie lotu
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['dodaj_lot'])) {
        // Dodanie nowego lotu
        dodajLot($db, $_POST);
    } elseif (isset($_POST['usun_lot'])) {
        // Usunięcie lotu na podstawie ID
        usunLot($db, $_POST['lot_id']);
    }
    // Przekierowanie po zakończeniu operacji
    header("Location: loty.php");
    exit();
}

// Pobieranie danych o lotach, liniach lotniczych, samolotach i terminalach
$data = pobierzDaneLotow($db);
$loty = $data['loty'];
$linie = $data['linie'];
$samoloty = $data['samoloty'];
$terminale = $data['terminale'];
?>

<!DOCTYPE html>
<html lang="pl">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portal Administratora - Loty</title>
    <link rel="stylesheet" href="css/style_1.css">
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

    <h1>Portal Administratora - Loty</h1>

    <nav>
        <a href="loty.php" class="button active">Loty</a>
        <a href="rezerwacje_loty.php" class="button">Rezerwacje</a>
        <a href="flota.php" class="button">Flota</a>
        <a href="infrastruktura.php" class="button">Infrastruktura</a>
        <a href="uzytkownicy.php" class="button">Użytkownicy</a>
        <a href="klient.php" class="button">Portal Klienta</a>
        <a href="logout.php" class="button logout">Wyloguj</a>
    </nav>

    <div class="loty-content-container">
        <div class="loty-form-container">
            <form method="POST">
                <h2>Dodaj nowy lot</h2>
                <label>Numer lotu:
                    <input type="text" name="numer_lotu" required>
                </label>
                <label>Linia lotnicza:
                    <select id="linia-lotnicza" name="linia_id" required>
                        <option value="" disabled selected>Wybierz linię lotniczą</option>
                        <?php foreach ($linie as $linia): ?>
                            <option value="<?= $linia['linia_id'] ?>"><?= $linia['nazwa'] ?></option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <label>Samolot:
                    <select id="samolot" name="samolot_id" required>
                        <option value="" disabled selected>Wybierz samolot</option>
                    </select>
                </label>
                <label>Terminal:
                    <select name="terminal_id" required>
                        <option value="" disabled selected>Wybierz terminal</option>
                        <?php foreach ($terminale as $terminal): ?>
                            <option value="<?= $terminal['terminal_id'] ?>"><?= $terminal['nazwa'] ?></option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <label>Początek:
                    <input type="text" name="poczatek" required>
                </label>
                <label>Cel:
                    <input type="text" name="cel" required>
                </label>
                <label>Odlot:
                    <input type="datetime-local" name="czas_odlotu" required>
                </label>
                <label>Przylot:
                    <input type="datetime-local" name="czas_przylotu" required>
                </label>
                <button type="submit" name="dodaj_lot">Dodaj lot</button>
            </form>
        </div>

        <div class="loty-table-container">
            <h2>Lista lotów</h2>
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
                        <th>Akcje</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($loty as $lot): ?>
                        <tr>
                            <td><?= $lot['numer_lotu'] ?></td>
                            <td><?= $lot['nazwa_linii'] ?></td>
                            <td><?= $lot['model_samolotu'] ?></td>
                            <td><?= $lot['terminal'] ?></td>
                            <td><?= $lot['poczatek'] ?></td>
                            <td><?= $lot['cel'] ?></td>
                            <td><?= $lot['czas_odlotu'] ?></td>
                            <td><?= $lot['czas_przylotu'] ?></td>
                            <td><?= $lot['liczba_rezerwacji'] ?>/<?= $lot['pojemnosc_samolotu'] ?></td>
                            <td>
                                <form method="POST">
                                    <input type="hidden" name="lot_id" value="<?= $lot['lot_id'] ?>">
                                    <button type="submit" name="usun_lot">Usuń</button>
                                </form>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        // Dynamiczne ładowanie samolotów dla wybranej linii lotniczej
        document.getElementById('linia-lotnicza').addEventListener('change', function () {
            const liniaId = this.value;
            const samolotSelect = document.getElementById('samolot');
            samolotSelect.innerHTML = '<option value="" disabled selected>Wybierz samolot</option>';

            // Pobranie samolotów przez API
            fetch(`get_planes.php?linia_id=${liniaId}`)
                .then(response => response.json())
                .then(data => {
                    data.forEach(samolot => {
                        const option = document.createElement('option');
                        option.value = samolot.samolot_id;
                        option.textContent = `${samolot.model} (ID: ${samolot.samolot_id})`;
                        samolotSelect.appendChild(option);
                    });
                })
                .catch(error => {
                    console.error('Błąd podczas pobierania samolotów:', error);
                });
        });
    </script>
</body>

</html>