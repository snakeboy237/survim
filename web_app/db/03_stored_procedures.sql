CREATE OR REPLACE PROCEDURE insert_detection(
    _image_id INT,
    _model_version TEXT,
    _detected_object TEXT,
    _confidence_score FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO detections(image_id, model_version, detected_object, confidence_score, timestamp)
    VALUES (_image_id, _model_version, _detected_object, _confidence_score, NOW());
END;
$$;
