<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json");

// Handle preflight CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  http_response_code(204);
  exit;
}

require '../settings/connection.php';

// Ensure POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
  http_response_code(405);
  echo json_encode(['status' => 'error', 'message' => 'Method Not Allowed']);
  exit;
}

// Read JSON body (preferred) or form-encoded fallback
$raw = file_get_contents('php://input');
$data = json_decode($raw, true);
if (!is_array($data)) {
  // Fallback to application/x-www-form-urlencoded
  $data = $_POST ?? [];
}

// Extract and sanitize inputs
$name = isset($data['name']) ? trim($data['name']) : '';
$phone = isset($data['phone']) ? trim($data['phone']) : '';
$email = isset($data['email']) ? trim($data['email']) : null;
$message = isset($data['message']) ? trim($data['message']) : null;

// Basic validation
$errors = [];
if ($name === '') $errors[] = 'name is required';
if ($phone === '') $errors[] = 'phone is required';

/**
 * Relaxed email validation:
 * - Accept empty email
 * - If provided, require simple presence of '@' to avoid false 422s from casual inputs.
 *   Adjust to stricter FILTER_VALIDATE_EMAIL if needed.
 */
if (!empty($email) && strpos($email, '@') === false) {
  $errors[] = 'email is invalid';
}

if (!empty($errors)) {
  http_response_code(422);
  echo json_encode(['status' => 'error', 'message' => 'Validation failed', 'errors' => $errors]);
  exit;
}

// Ensure table exists (idempotent creation)
try {
  $pdo->exec("
    CREATE TABLE IF NOT EXISTS CareerCounselling (
      id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      phone VARCHAR(20) NOT NULL,
      email VARCHAR(120) NULL,
      message TEXT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
  ");
} catch (Exception $e) {
  http_response_code(500);
  echo json_encode(['status' => 'error', 'message' => 'Failed ensuring table', 'detail' => $e->getMessage()]);
  exit;
}

// Insert row
try {
  $stmt = $pdo->prepare("
    INSERT INTO CareerCounselling (name, phone, email, message)
    VALUES (:name, :phone, :email, :message)
  ");
  $stmt->execute([
    ':name' => $name,
    ':phone' => $phone,
    ':email' => $email,
    ':message' => $message
  ]);

  $insertId = $pdo->lastInsertId();

  echo json_encode([
    'status' => 'success',
    'id' => $insertId,
    'message' => 'Counselling request saved'
  ]);
} catch (Exception $e) {
  http_response_code(500);
  echo json_encode(['status' => 'error', 'message' => 'Insert failed', 'detail' => $e->getMessage()]);
  exit;
}
