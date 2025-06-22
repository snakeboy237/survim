CREATE OR REPLACE VIEW recent_detections AS
SELECT d.id, i.filename, d.detected_object, d.confidence_score, d.timestamp
FROM detections d
JOIN images i ON d.image_id = i.id
WHERE d.timestamp > NOW() - INTERVAL '7 days';
