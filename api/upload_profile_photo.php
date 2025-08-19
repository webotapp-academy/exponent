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
        'message' => 'Method Not Allowed',
        'debug' => [
            'method' => $_SERVER['REQUEST_METHOD']
        ]
    ]);
    exit();
}

// Include database connection
require_once '../settings/connection.php';

// Validate input with detailed logging
function validateInput() {
    $errors = [];

    // Check user ID
    if (!isset($_POST['user_id']) || empty(trim($_POST['user_id']))) {
        $errors[] = 'Missing user ID';
    }

    // Check file upload
    if (!isset($_FILES['profile_photo'])) {
        $errors[] = 'No file uploaded';
    } elseif ($_FILES['profile_photo']['error'] !== UPLOAD_ERR_OK) {
        $errors[] = 'File upload error: ' . $_FILES['profile_photo']['error'];
    }

    return $errors;
}

// Validate inputs
$validationErrors = validateInput();
if (!empty($validationErrors)) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Validation failed',
        'errors' => $validationErrors,
        'debug' => [
            'post_data' => $_POST,
            'files' => $_FILES
        ]
    ]);
    exit();
}

// Sanitize and validate user ID
$userId = filter_var($_POST['user_id'], FILTER_VALIDATE_INT);
if ($userId === false) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Invalid user ID',
        'debug' => [
            'raw_user_id' => $_POST['user_id']
        ]
    ]);
    exit();
}

// File upload configuration
$uploadDir = '../uploads/profile_photos/';
$maxFileSize = 5 * 1024 * 1024; // 5MB

// Create uploads directory if it doesn't exist
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

// Validate file
$file = $_FILES['profile_photo'];

if ($file['size'] > $maxFileSize) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error', 
        'message' => 'File too large. Maximum 5MB allowed.',
        'debug' => [
            'file_size' => $file['size'],
            'max_size' => $maxFileSize
        ]
    ]);
    exit();
}

// Improved MIME type detection
function detectMimeType($filePath) {
    // Try to use finfo first
    if (function_exists('finfo_open')) {
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mimeType = finfo_file($finfo, $filePath);
        finfo_close($finfo);
        return $mimeType;
    }

    // Fallback to extension-based detection
    $extension = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));
    $mimeTypes = [
        'jpg'  => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'png'  => 'image/png',
        'gif'  => 'image/gif'
    ];

    return $mimeTypes[$extension] ?? 'application/octet-stream';
}

// Detect MIME type
$detectedMimeType = detectMimeType($file['tmp_name']);
$allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];

// Validate MIME type
if (!in_array($detectedMimeType, $allowedTypes)) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error', 
        'message' => 'Invalid file type. Only JPEG, PNG, and GIF allowed.',
        'debug' => [
            'detected_type' => $detectedMimeType,
            'allowed_types' => $allowedTypes,
            'file_name' => $file['name']
        ]
    ]);
    exit();
}

// Generate unique filename
$fileExtension = pathinfo($file['name'], PATHINFO_EXTENSION);
$newFilename = "user_{$userId}_profile_" . uniqid() . "." . $fileExtension;
$uploadPath = $uploadDir . $newFilename;
$webPath = "uploads/profile_photos/" . $newFilename;

// Move uploaded file
if (move_uploaded_file($file['tmp_name'], $uploadPath)) {
    try {
        // Update user's profile photo in database
        $stmt = $pdo->prepare("
            UPDATE Users 
            SET profile_photo = :photo_url 
            WHERE UserID = :user_id
        ");

        $result = $stmt->execute([
            ':photo_url' => $webPath,
            ':user_id' => $userId
        ]);

        if ($result) {
            http_response_code(200);
            echo json_encode([
                'status' => 'success', 
                'message' => 'Profile photo uploaded successfully',
                'photo_url' => $webPath,
                'debug' => [
                    'user_id' => $userId,
                    'file_path' => $uploadPath,
                    'mime_type' => $detectedMimeType
                ]
            ]);
        } else {
            throw new Exception('Failed to update database');
        }
    } catch (Exception $e) {
        // Remove uploaded file if database update fails
        unlink($uploadPath);

        http_response_code(500);
        echo json_encode([
            'status' => 'error', 
            'message' => 'Database update failed',
            'debug' => [
                'error' => $e->getMessage(),
                'user_id' => $userId
            ]
        ]);
    }
} else {
    http_response_code(500);
    echo json_encode([
        'status' => 'error', 
        'message' => 'File upload failed',
        'debug' => [
            'tmp_name' => $file['tmp_name'],
            'upload_path' => $uploadPath
        ]
    ]);
}
