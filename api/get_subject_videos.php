<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require '../settings/connection.php';

/*
DB structure (Videos):
  - VideoID (PK, int)
  - TopicID (FK, int)  // points to a topic within a subject
  - Title (varchar)
  - URL (varchar)
  - Thumbnail (varchar)

Inputs (GET):
  - course_id (int, required)   // used to scope topics by course
  - subject_id (int, required)  // used to scope topics by subject

Assumed relations:
  Subjects: SubjectID, CourseID, ...
  Topics:   TopicID, SubjectID, CourseID, Title, ...
  Videos:   VideoID, TopicID, Title, URL, Thumbnail

If your Topics table uses different column names, adjust the JOIN and WHERE.
Output (JSON):
  {
    "status": "success",
    "videos": [
      {
        "VideoID": 1,
        "TopicID": 10,
        "Title": "Introduction to Algebra",
        "URL": "https://example.com/videos/1.mp4",
        "Thumbnail": "https://example.com/thumbs/1.jpg"
      }
    ]
  }
On error:
  { "status": "error", "message": "..." }
*/

// Helper: send error response and exit
function send_error($message, $httpCode = 400) {
    http_response_code($httpCode);
    echo json_encode(["status" => "error", "message" => $message]);
    exit;
}

try {
    // Validate inputs
    $courseId = isset($_GET['course_id']) ? (int)$_GET['course_id'] : 0;
    $subjectId = isset($_GET['subject_id']) ? (int)$_GET['subject_id'] : 0;

    if ($courseId <= 0 || $subjectId <= 0) {
        send_error("Invalid parameters: course_id and subject_id are required positive integers", 400);
    }

    // Fetch videos that belong to the given course and subject
    // via Topics (Videos.TopicID -> Topics.TopicID).
    // Adjust table/column names if your schema differs.
    $sql = "SELECT 
                v.VideoID,
                v.TopicID,
                v.Title,
                v.URL,
                v.Thumbnail
            FROM Videos v
            INNER JOIN Topics t ON t.TopicID = v.TopicID
            WHERE t.CourseID = :courseId
              AND t.SubjectID = :subjectId
            ORDER BY v.VideoID DESC";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        ':courseId' => $courseId,
        ':subjectId' => $subjectId
    ]);

    $videos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "status" => "success",
        "videos" => $videos
    ]);
} catch (Throwable $e) {
    // You can log $e->getMessage() server-side for debugging if needed.
    send_error("Server error", 500);
}
