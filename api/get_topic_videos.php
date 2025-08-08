
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
    VideoID AS id,
    TopicID AS topic_id,
    Title AS title,
    URL AS url,
    Thumbnail AS thumbnail,
    COALESCE(DurationSeconds,0) AS duration_seconds,
    Provider AS provider,
    Quality AS quality
  FROM Videos
  WHERE TopicID = :topic_id
    AND COALESCE(IsActive,1)=1
  ORDER BY COALESCE(DisplayOrder, VideoID)
";
$stmt = $pdo->prepare($sql);
$stmt->execute(['topic_id' => $topicId]);
$videos = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(['status' => 'success', 'videos' => $videos]);