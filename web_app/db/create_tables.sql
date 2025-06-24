CREATE TABLE images (
    id SERIAL PRIMARY KEY,
    s3_key TEXT NOT NULL,  -- S3 object key
    original_filename TEXT NOT NULL,
    upload_time TIMESTAMP DEFAULT NOW(),
    status TEXT DEFAULT 'pending',  -- pending, processed, error
    notes TEXT
);

CREATE TABLE detections (
    id SERIAL PRIMARY KEY,
    image_id INT REFERENCES images(id) ON DELETE CASCADE,
    model_version TEXT,
    detected_object TEXT,
    confidence_score FLOAT,
    detected_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE logs (
    id SERIAL PRIMARY KEY,
    image_id INT REFERENCES images(id) ON DELETE CASCADE,
    log_message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE new (
    id SERIAL PRIMARY KEY,
    notes TEXT
    notessds TEXT
);
