<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require '../settings/connection.php';

$stmt = $pdo->query("SELECT * FROM Subjects");
$subjects = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(['status' => 'success', 'subjects' => $subjects]);
?>
