CREATE OR REPLACE VIEW recent_uploads AS
SELECT id, s3_key, original_filename, upload_time, status
FROM images
WHERE upload_time > NOW() - INTERVAL '7 days';
