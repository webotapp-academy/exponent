
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

$counts = [
  'materials_count' => 0,
  'notes_count' => 0,
  'videos_count' => 0,
];

$stmt = $pdo->prepare("SELECT COUNT(*) c FROM StudyMaterials WHERE TopicID=:id AND COALESCE(IsActive,1)=1");
$stmt->execute(['id' => $topicId]);
$counts['materials_count'] = (int)$stmt->fetchColumn();

$stmt = $pdo->prepare("SELECT COUNT(*) c FROM Notes WHERE TopicID=:id AND COALESCE(IsActive,1)=1");
$stmt->execute(['id' => $topicId]);
$counts['notes_count'] = (int)$stmt->fetchColumn();

$stmt = $pdo->prepare("SELECT COUNT(*) c FROM Videos WHERE TopicID=:id AND COALESCE(IsActive,1)=1");
$stmt->execute(['id' => $topicId]);
$counts['videos_count'] = (int)$stmt->fetchColumn();

echo json_encode(['status' => 'success'] + $counts);