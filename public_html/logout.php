<?php
// Rozpoczęcie sesji, aby umożliwić jej zniszczenie
session_start();

// Zniszczenie sesji użytkownika (wylogowanie)
session_destroy();

// Przekierowanie użytkownika na stronę logowania (auth.php)
header("Location: auth.php");
exit(); // Kończenie dalszego wykonywania skryptu po przekierowaniu
?>