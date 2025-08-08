 
<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require '../settings/connection.php';

$topicId = isset($_GET['topic_id']) ? (int)$_GET['topic_id'] : 0;
if ($topicId <= 0) {
  http_response_code(400);
  echo json_encode(['status' => 'error', 'message' => 'topic_id required']);
  exit;
}

$sql = "
  SELECT 
    MaterialID AS id,
    TopicID AS topic_id,
    Title AS title,
    Type AS type,              -- 'Notes','Worksheets','Summary','Practice','PDF'
    URL AS url,
    COALESCE(Pages,0) AS pages,
    ThumbnailURL AS thumbnail,
    Description AS description
  FROM StudyMaterials
  WHERE TopicID = :topic_id
    AND COALESCE(IsActive,1)=1
  ORDER BY COALESCE(DisplayOrder, MaterialID)
";
$stmt = $pdo->prepare($sql);
$stmt->execute(['topic_id' => $topicId]);
$materials = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(['status' => 'success', 'materials' => $materials]);