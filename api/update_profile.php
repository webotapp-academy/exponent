<?php
// Enable CORS and set content type
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Ensure only POST requests are processed
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Method Not Allowed'
    ]);
    exit();
}

// Include database connection
require_once '../settings/connection.php';

// Validate input
$requiredFields = ['user_id', 'name', 'email', 'phone', 'address', 'class'];
$missingFields = [];

foreach ($requiredFields as $field) {
    if (!isset($_POST[$field]) || empty(trim($_POST[$field]))) {
        $missingFields[] = $field;
    }
}

if (!empty($missingFields)) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Missing required fields: ' . implode(', ', $missingFields)
    ]);
    exit();
}

// Sanitize and validate inputs
$userId = filter_var($_POST['user_id'], FILTER_VALIDATE_INT);
$name = trim($_POST['name']);
$email = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
$phone = trim($_POST['phone']);
$address = trim($_POST['address']);
$class = trim($_POST['class']);

if (!$userId || !$email) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Invalid user ID or email format'
    ]);
    exit();
}

try {
    // Prepare SQL to update user profile
    $stmt = $pdo->prepare("
        UPDATE Users 
        SET 
            Name = :name, 
            Email = :email, 
            Userphone = :phone, 
            address = :address, 
            UserType = :class 
        WHERE UserID = :user_id
    ");

    // Execute the update
    $result = $stmt->execute([
        ':name' => $name,
        ':email' => $email,
        ':phone' => $phone,
        ':address' => $address,
        ':class' => $class,
        ':user_id' => $userId
    ]);

    if ($result) {
        // Fetch updated user data to return
        $fetchStmt = $pdo->prepare("
            SELECT UserID, Name, Email, Userphone, address, UserType 
            FROM Users 
            WHERE UserID = :user_id
        ");
        $fetchStmt->execute([':user_id' => $userId]);
        $updatedUser = $fetchStmt->fetch(PDO::FETCH_ASSOC);

        http_response_code(200);
        echo json_encode([
            'status' => 'success', 
            'message' => 'Profile updated successfully',
            'user' => $updatedUser
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            'status' => 'error', 
            'message' => 'Failed to update profile'
        ]);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Database error: ' . $e->getMessage()
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Unexpected error: ' . $e->getMessage()
    ]);
}
