DROP TABLE IF EXISTS t7_hw_taxi_daily;

CREATE TABLE t7_hw_taxi_daily (
    pickup_zone_id  INTEGER NOT NULL,
    ts_day          DATE    NOT NULL,
    trip_count      INTEGER NOT NULL CHECK (trip_count >= 0),
    avg_fare        NUMERIC(10, 2) NOT NULL CHECK (avg_fare >= 0),
    total_distance  NUMERIC(12, 2) NOT NULL CHECK (total_distance >= 0),
    PRIMARY KEY (pickup_zone_id, ts_day)
);

INSERT INTO t7_hw_taxi_daily (
    pickup_zone_id,
    ts_day,
    trip_count,
    avg_fare,
    total_distance
)
SELECT
    z.zone_id,
    DATE '2024-03-31' - (59 - n) AS ts_day,
    500 + (n * 7) + z.zone_id * 50 + (n % 5) * 30 AS trip_count,
    (12.5 + z.zone_id * 0.7 + (n % 4) * 0.4)::NUMERIC(10, 2) AS avg_fare,
    (1500 + n * 25 + z.zone_id * 120)::NUMERIC(12, 2) AS total_distance
FROM generate_series(0, 59) AS n
CROSS JOIN (VALUES (1), (2), (3), (4), (5)) AS z(zone_id);
