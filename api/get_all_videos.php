<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require '../settings/connection.php';

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
  WHERE COALESCE(IsActive,1)=1
  ORDER BY COALESCE(DisplayOrder, VideoID)
";
$stmt = $pdo->prepare($sql);
$stmt->execute();
$videos = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(['status' => 'success', 'videos' => $videos]);