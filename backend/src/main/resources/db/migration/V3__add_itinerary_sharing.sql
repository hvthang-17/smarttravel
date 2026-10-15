ALTER TABLE itineraries ADD COLUMN share_token VARCHAR(100) UNIQUE NULL;
ALTER TABLE itineraries ADD COLUMN version INT NOT NULL DEFAULT 1;
CREATE INDEX idx_itineraries_share_token ON itineraries (share_token);
