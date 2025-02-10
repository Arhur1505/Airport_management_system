<?php
session_start();

// Sprawdzenie, czy jesteś zalogowany i masz rolę admin
if (!isset($_SESSION['logged_in']) || $_SESSION['role'] !== 'admin') {
    header("Location: auth.php");
    exit();
}

// Połączenie z bazą i wczytanie funkcji
require_once 'db.php';
require_once 'functions.php';

$success = null;
$error = null;

// Obsługa usunięcia użytkownika
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['usun_uzytkownika'])) {
    $u_id = $_POST['u_id'];
    try {
        usunUzytkownika($db, $u_id);
        header("Location: uzytkownicy.php?msg=deleted");
        exit();
    } catch (PDOException $e) {
        $error = "Wystąpił błąd podczas usuwania użytkownika: " . $e->getMessage();
    }
}

// Jeśli przychodzimy po przekierowaniu z info o udanym usunięciu
if (isset($_GET['msg']) && $_GET['msg'] === 'deleted') {
    $success = "Użytkownik został pomyślnie usunięty.";
}

// Pobieramy listę użytkowników z widoku
$uzytkownicy = pobierzWszystkichUzytkownikowWidok($db);
?>
<!DOCTYPE html>
<html lang="pl">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Portal Administratora - Użytkownicy</title>
    <link rel="stylesheet" href="css/style_4.css">
</head>

<body>

    <h1>Portal Administratora - Użytkownicy</h1>

    <nav>
        <a href="loty.php" class="button">Loty</a>
        <a href="rezerwacje_loty.php" class="button">Rezerwacje</a>
        <a href="flota.php" class="button">Flota</a>
        <a href="infrastruktura.php" class="button">Infrastruktura</a>
        <a href="uzytkownicy.php" class="button active">Użytkownicy</a>
        <a href="klient.php" class="button">Portal Klienta</a>
        <a href="logout.php" class="button logout">Wyloguj</a>
    </nav>

    <div class="content-container">
        <div class="form-container">
            <h2>Lista zarejestrowanych użytkowników</h2>

            <?php if ($success): ?>
                <p style="color: green;"><?= htmlspecialchars($success) ?></p>
            <?php endif; ?>

            <?php if ($error): ?>
                <p style="color: red;"><?= htmlspecialchars($error) ?></p>
            <?php endif; ?>

            <?php if (!empty($uzytkownicy)): ?>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Imię</th>
                            <th>Nazwisko</th>
                            <th>Email</th>
                            <th>Telefon</th>
                            <th>Rola</th>
                            <th>Data rejestracji</th>
                            <th>Liczba rezerwacji</th>
                            <th>Akcje</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($uzytkownicy as $u): ?>
                            <tr>
                                <td><?= htmlspecialchars($u['u_id']) ?></td>
                                <td><?= htmlspecialchars($u['imie']) ?></td>
                                <td><?= htmlspecialchars($u['nazwisko']) ?></td>
                                <td><?= htmlspecialchars($u['email']) ?></td>
                                <td><?= htmlspecialchars($u['telefon']) ?></td>
                                <td><?= htmlspecialchars($u['rola']) ?></td>
                                <td><?= htmlspecialchars($u['data_rejestracji']) ?></td>
                                <td><?= htmlspecialchars($u['liczba_rezerwacji']) ?></td>
                                <td>
                                    <form method="POST" style="display:inline;">
                                        <input type="hidden" name="u_id" value="<?= htmlspecialchars($u['u_id']) ?>">
                                        <button type="submit" name="usun_uzytkownika" class="button-danger">
                                            Usuń
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            <?php else: ?>
                <p>Brak zarejestrowanych użytkowników w systemie.</p>
            <?php endif; ?>
        </div>
    </div>

</body>

</html>