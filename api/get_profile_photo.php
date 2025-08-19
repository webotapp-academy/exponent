<?php
// Enable CORS and set content type
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Ensure only GET requests are processed
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Method Not Allowed'
    ]);
    exit();
}

// Include database connection
require_once '../settings/connection.php';

// Validate user ID
if (!isset($_GET['user_id']) || empty(trim($_GET['user_id']))) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error', 
        'message' => 'User ID is required'
    ]);
    exit();
}

// Sanitize user ID
$userId = filter_var($_GET['user_id'], FILTER_VALIDATE_INT);
if ($userId === false) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Invalid user ID'
    ]);
    exit();
}

try {
    // Prepare and execute query to fetch profile photo
    $stmt = $pdo->prepare("
        SELECT profile_photo 
        FROM Users 
        WHERE UserID = :user_id
    ");
    $stmt->execute([':user_id' => $userId]);
    
    // Fetch the result
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user && !empty($user['profile_photo'])) {
        // Construct full URL 
        $baseUrl = 'https://indiawebdesigns.in/app/eduapp/user-app/';
        $fullPhotoUrl = $baseUrl . $user['profile_photo'];
        
        http_response_code(200);
        echo json_encode([
            'status' => 'success', 
            'photo_url' => $fullPhotoUrl
        ]);
    } else {
        http_response_code(404);
        echo json_encode([
            'status' => 'error', 
            'message' => 'No profile photo found'
        ]);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Database error: ' . $e->getMessage()
    ]);
}
exit();
