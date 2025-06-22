CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username TEXT NOT NULL,
    email TEXT NOT NULL,
    password_hash TEXT NOT NULL
);

CREATE TABLE images (
    id SERIAL PRIMARY KEY,
    filename TEXT NOT NULL,
    upload_time TIMESTAMP DEFAULT NOW(),
    user_id INT REFERENCES users(id),
    processing_status TEXT
);

CREATE TABLE detections (
    id SERIAL PRIMARY KEY,
    image_id INT REFERENCES images(id),
    model_version TEXT,
    detected_object TEXT,
    confidence_score FLOAT,
    timestamp TIMESTAMP DEFAULT NOW()
);

CREATE TABLE logs (
    id SERIAL PRIMARY KEY,
    detection_id INT REFERENCES detections(id),
    log_message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
