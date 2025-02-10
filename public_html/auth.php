<?php
session_start();
require 'db.php';

// Sprawdzenie, czy żądanie zostało wysłane metodą POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Logowanie użytkownika
    if (isset($_POST['action']) && $_POST['action'] === 'login') {
        $email = $_POST['email'];
        $password = $_POST['password'];

        // Przygotowanie i wykonanie zapytania SQL do pobrania użytkownika
        $stmt = $db->prepare("
            SELECT u_id, haslo, rola 
            FROM zarzadzanie_lotniskiem_v2.Uzytkownicy 
            WHERE email = :email
        ");
        $stmt->bindParam(':email', $email);
        $stmt->execute();
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        // Sprawdzenie poprawności hasła i logowanie użytkownika
        if ($user && password_verify($password, $user['haslo'])) {
            $_SESSION['logged_in'] = true;
            $_SESSION['user_id'] = $user['u_id'];
            $_SESSION['role'] = $user['rola'];

            // Przekierowanie w zależności od roli użytkownika
            if ($user['rola'] === 'admin') {
                header("Location: loty.php");
            } elseif ($user['rola'] === 'klient') {
                header("Location: klient.php");
            }
            exit(); // Zatrzymanie dalszego wykonywania kodu po przekierowaniu
        } else {
            $error = "Nieprawidłowy email lub hasło.";
        }
    // Rejestracja nowego użytkownika
    } elseif (isset($_POST['action']) && $_POST['action'] === 'register') {
        // Pobranie i przetworzenie danych z formularza rejestracyjnego
        $email = htmlspecialchars($_POST['email']);
        $password = password_hash($_POST['password'], PASSWORD_DEFAULT);
        $role = $_POST['role'];
        $imie = htmlspecialchars($_POST['imie']);
        $nazwisko = htmlspecialchars($_POST['nazwisko']);
        $telefon = htmlspecialchars($_POST['telefon']);

        try {
            // Przygotowanie zapytania do dodania nowego użytkownika
            $stmt = $db->prepare("
                INSERT INTO zarzadzanie_lotniskiem_v2.Uzytkownicy (email, haslo, rola, imie, nazwisko, telefon)
                VALUES (:email, :password, :role, :imie, :nazwisko, :telefon)
            ");
            $stmt->bindParam(':email', $email);
            $stmt->bindParam(':password', $password);
            $stmt->bindParam(':role', $role);
            $stmt->bindParam(':imie', $imie);
            $stmt->bindParam(':nazwisko', $nazwisko);
            $stmt->bindParam(':telefon', $telefon);
            $stmt->execute();

            $success = "Rejestracja zakończona sukcesem! Możesz się teraz zalogować.";
        } catch (PDOException $e) {
            if ($e->getCode() == 23505) {
                $error = "Email jest już zajęty.";
            } else {
                $error = "Wystąpił błąd: " . htmlspecialchars($e->getMessage());
            }
        }
    }
}
?>

<!DOCTYPE html>
<html lang="pl">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Logowanie i Rejestracja</title>
    <link rel="stylesheet" href="css/style_5.css">
</head>

<body>
    <div class="container">
        <div class="form-container">
            <h1>Lotnisko</h1>
            <p>Wybierz logowanie lub zarejestruj się.</p>

            <?php if (isset($error)): ?>
                <p style="color: red;"><?= $error ?></p>
            <?php endif; ?>

            <?php if (isset($success)): ?>
                <p style="color: green;"><?= $success ?></p>
            <?php endif; ?>

            <div class="toggle-buttons">
                <button id="login-btn" class="active" onclick="showLogin()">Logowanie</button>
                <button id="register-btn" onclick="showRegister()">Rejestracja</button>
            </div>

            <form id="login-form" method="POST">
                <h2>Logowanie</h2>
                <label>Email:</label>
                <input type="email" name="email" required>
                <label>Hasło:</label>
                <input type="password" name="password" required>
                <input type="hidden" name="action" value="login">
                <button type="submit">Zaloguj się</button>
            </form>

            <form id="register-form" method="POST" style="display: none;">
                <h2>Rejestracja</h2>
                <label>Email:</label>
                <input type="email" name="email" required>
                <label>Hasło:</label>
                <input type="password" name="password" required>
                <label>Imię:</label>
                <input type="text" name="imie" required>
                <label>Nazwisko:</label>
                <input type="text" name="nazwisko" required>
                <label>Telefon:</label>
                <input type="text" name="telefon" required>
                <label>Rola:</label>
                <select name="role" required>
                    <option value="admin">Admin</option>
                    <option value="klient">Klient</option>
                </select>
                <input type="hidden" name="action" value="register">
                <button type="submit">Zarejestruj się</button>
            </form>
        </div>
    </div>

    <script>
        function showLogin() {
            document.getElementById('login-form').style.display = 'block';
            document.getElementById('register-form').style.display = 'none';
            document.getElementById('login-btn').classList.add('active');
            document.getElementById('register-btn').classList.remove('active');
        }

        function showRegister() {
            document.getElementById('login-form').style.display = 'none';
            document.getElementById('register-form').style.display = 'block';
            document.getElementById('register-btn').classList.add('active');
            document.getElementById('login-btn').classList.remove('active');
        }
    </script>
</body>

</html>