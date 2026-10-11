CREATE OR REPLACE VIEW v_t7_hw_taxi_features AS
WITH features_basic AS (
    SELECT
        pickup_zone_id,
        ts_day,
        trip_count,
        avg_fare,
        total_distance,

        LAG(trip_count, 1)  OVER w_pid AS trips_lag_1d,
        LAG(trip_count, 7)  OVER w_pid AS trips_lag_7d,
        LAG(trip_count, 30) OVER w_pid AS trips_lag_30d,

        AVG(avg_fare) OVER w7 AS rolling_avg_fare_7d,
        STDDEV_SAMP(avg_fare) OVER w30 AS rolling_std_fare_30d,

        SUM(trip_count) OVER we AS cumulative_trips,
        AVG(trip_count) OVER we AS expanding_avg_trips
    FROM t7_hw_taxi_daily
    WINDOW
        w_pid AS (
            PARTITION BY pickup_zone_id
            ORDER BY ts_day
        ),
        w7 AS (
            PARTITION BY pickup_zone_id
            ORDER BY ts_day::TIMESTAMP
            RANGE BETWEEN INTERVAL '6 days' PRECEDING AND CURRENT ROW
        ),
        w30 AS (
            PARTITION BY pickup_zone_id
            ORDER BY ts_day::TIMESTAMP
            RANGE BETWEEN INTERVAL '29 days' PRECEDING AND CURRENT ROW
        ),
        we AS (
            PARTITION BY pickup_zone_id
            ORDER BY ts_day
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )
)
SELECT *
FROM features_basic
WHERE trips_lag_30d IS NOT NULL;
