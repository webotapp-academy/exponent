<?php
// Set the log file path
$log_file = __DIR__ . '/independence_day_names.txt';

// Get the name from POST request
$name = isset($_POST['name']) ? trim($_POST['name']) : '';

// Validate name
if (!empty($name)) {
    // Prepare log entry with timestamp
    $log_entry = date('Y-m-d H:i:s') . " | " . $name . "\n";
    
    // Append to log file
    file_put_contents($log_file, $log_entry, FILE_APPEND | LOCK_EX);
    
    // Return success response
    echo json_encode(['status' => 'success', 'message' => 'Name logged successfully']);
} else {
    // Return error response
    echo json_encode(['status' => 'error', 'message' => 'Invalid name']);
}
?>
