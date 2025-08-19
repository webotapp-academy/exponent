<?php
// Enable CORS headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Ensure only POST requests are processed
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header("Allow: POST");
    http_response_code(405);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Method Not Allowed. Only POST requests are supported.',
        'allowed_methods' => ['POST']
    ]);
    exit();
}

// Debugging: Log raw request data
error_log('Raw POST Data: ' . print_r($_POST, true));
error_log('Raw Request Method: ' . $_SERVER['REQUEST_METHOD']);

// Include database connection
require_once '../settings/connection.php';

// Check if data was actually sent
if (empty($_POST)) {
    // Try to parse raw POST data
    $rawPostData = file_get_contents('php://input');
    $postData = json_decode($rawPostData, true);
    
    if ($postData === null) {
        http_response_code(400);
        echo json_encode([
            'status' => 'error', 
            'message' => 'No data received',
            'raw_input' => $rawPostData
        ]);
        exit();
    }
    
    // Override $_POST with parsed data
    $_POST = $postData;
}

// Validate and sanitize input
$requiredFields = [
    'user_id', 
    'student_name', 
    'mobile_number', 
    'gender', 
    'father_name', 
    'parent_mobile', 
    'college_name', 
    'tenth_percentage'
];

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
        'message' => 'Missing required fields: ' . implode(', ', $missingFields),
        'received_data' => $_POST
    ]);
    exit();
}

// Sanitize and validate inputs
$userId = filter_var($_POST['user_id'], FILTER_VALIDATE_INT);
$studentName = trim($_POST['student_name']);
$mobileNumber = trim($_POST['mobile_number']);
$gender = trim($_POST['gender']);
$fatherName = trim($_POST['father_name']);
$parentMobile = trim($_POST['parent_mobile']);
$collegeName = trim($_POST['college_name']);
$tenthPercentage = trim($_POST['tenth_percentage']);

// Validate user ID
if ($userId === false) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Invalid user ID',
        'received_user_id' => $_POST['user_id']
    ]);
    exit();
}

// Validate mobile numbers
if (!preg_match('/^[6-9]\d{9}$/', $mobileNumber)) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Invalid student mobile number'
    ]);
    exit();
}

if (!preg_match('/^[6-9]\d{9}$/', $parentMobile)) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Invalid parent mobile number'
    ]);
    exit();
}

// Validate percentage
if (!is_numeric($tenthPercentage) || $tenthPercentage < 0 || $tenthPercentage > 100) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Invalid 10th percentage'
    ]);
    exit();
}

try {
    // Check if user has already registered
    $checkStmt = $pdo->prepare("
        SELECT id FROM neet_registrations 
        WHERE user_id = :user_id
    ");
    $checkStmt->execute([':user_id' => $userId]);
    
    if ($checkStmt->fetch()) {
        http_response_code(409);
        echo json_encode([
            'status' => 'error', 
            'message' => 'You have already registered for NEET Test Series'
        ]);
        exit();
    }

    // Prepare SQL to insert registration
    $stmt = $pdo->prepare("
        INSERT INTO neet_registrations (
            user_id,
            student_name, 
            mobile_number, 
            gender, 
            father_name, 
            parent_mobile, 
            college_name, 
            tenth_percentage
        ) VALUES (
            :user_id,
            :student_name, 
            :mobile_number, 
            :gender, 
            :father_name, 
            :parent_mobile, 
            :college_name, 
            :tenth_percentage
        )
    ");

    // Execute the statement
    $result = $stmt->execute([
        ':user_id' => $userId,
        ':student_name' => $studentName,
        ':mobile_number' => $mobileNumber,
        ':gender' => $gender,
        ':father_name' => $fatherName,
        ':parent_mobile' => $parentMobile,
        ':college_name' => $collegeName,
        ':tenth_percentage' => $tenthPercentage
    ]);

    if ($result) {
        // Get the ID of the newly inserted registration
        $registrationId = $pdo->lastInsertId();

        http_response_code(201);
        echo json_encode([
            'status' => 'success', 
            'message' => 'Registration successful',
            'registration_id' => $registrationId
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            'status' => 'error', 
            'message' => 'Failed to save registration'
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
