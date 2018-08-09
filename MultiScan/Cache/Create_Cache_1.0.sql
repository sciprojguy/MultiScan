CREATE TABLE IF NOT EXISTS Scans (
    Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    Type TEXT NOT NULL,
    Latitude FLOAT,
    Longitude FLOAT,
    Address TEXT,
    Captured DATETIME NOT NULL,
    Payload TEXT NOT NULL,
    CapturedImage BLOB
);
CREATE TABLE IF NOT EXISTS Version (
    version TEXT NOT NULL
);
DELETE FROM Version;
INSERT INTO Version (version) VALUES('1.0');
