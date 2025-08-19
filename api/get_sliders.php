<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }

require '../settings/connection.php';

try {
  $stmt = $pdo->prepare("
    SELECT id, image_path, title, description 
    FROM sliders 
    WHERE is_active = 1 
    ORDER BY display_order
  ");
  $stmt->execute();
  $sliders = $stmt->fetchAll(PDO::FETCH_ASSOC);

  if (empty($sliders)) {
    // Provide default sliders if no active sliders found
    $sliders = [
      [
        'id' => 1,
        'image_path' => 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=1200&auto=format&fit=crop&q=70',
        'title' => 'Welcome to Exponent Classes',
        'description' => 'Your path to academic excellence'
      ],
      [
        'id' => 2,
        'image_path' => 'https://images.unsplash.com/photo-1503676382389-4809596d5290?w=1200&auto=format&fit=crop&q=70',
        'title' => 'Comprehensive Learning',
        'description' => 'Innovative teaching methods'
      ]
    ];
  }

  echo json_encode([
    'status' => 'success',
    'sliders' => $sliders
  ]);
} catch (PDOException $e) {
  http_response_code(500);
  echo json_encode([
    'status' => 'error',
    'message' => 'Database error: ' . $e->getMessage()
  ]);
}
?>
