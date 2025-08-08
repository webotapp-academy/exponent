 
<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require '../settings/connection.php';

$subjectId = isset($_GET['subject_id']) ? (int)$_GET['subject_id'] : 0;
if ($subjectId <= 0) {
  http_response_code(400);
  echo json_encode(['status' => 'error', 'message' => 'subject_id required']);
  exit;
}

$sql = "
  SELECT 
    TopicID AS id,
    SubjectID AS subject_id,
    Name AS title,
    Description AS description,
    COALESCE(ChapterNumber, 0) AS chapter_number,
    COALESCE(DurationMinutes, 0) AS duration_minutes,
    ThumbnailURL AS thumbnail
  FROM Topics
  WHERE SubjectID = :subject_id
    AND COALESCE(IsActive,1)=1
  ORDER BY COALESCE(DisplayOrder, ChapterNumber, TopicID)
";
$stmt = $pdo->prepare($sql);
$stmt->execute(['subject_id' => $subjectId]);
$topics = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(['status' => 'success', 'topics' => $topics]);