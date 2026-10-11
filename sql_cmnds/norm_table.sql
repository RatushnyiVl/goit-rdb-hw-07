DROP TABLE IF EXISTS t7_hw_checkouts_norm;

CREATE TABLE t7_hw_checkouts_norm (
    event_id        INTEGER PRIMARY KEY,
    user_id         INTEGER NOT NULL,
    event_ts        TIMESTAMPTZ NOT NULL,
    order_id        TEXT NOT NULL,
    total           NUMERIC(10, 2) NOT NULL,
    items_count     INTEGER NOT NULL CHECK (items_count > 0),
    payment_method  TEXT NOT NULL CHECK (payment_method IN ('card', 'paypal', 'crypto'))
);

INSERT INTO t7_hw_checkouts_norm (
    event_id,
    user_id,
    event_ts,
    order_id,
    total,
    items_count,
    payment_method
)
SELECT
    event_id,
    user_id,
    event_ts,
    payload ->> 'order_id' AS order_id,
    (payload ->> 'total')::NUMERIC(10, 2) AS total,
    (payload ->> 'items_count')::INTEGER AS items_count,
    payload ->> 'payment_method' AS payment_method
FROM t7_hw_events
WHERE event_type = 'checkout';

CREATE INDEX idx_t7_checkouts_norm_pm
    ON t7_hw_checkouts_norm (payment_method);

ANALYZE t7_hw_checkouts_norm;

SELECT COUNT(*) AS n_checkouts
FROM t7_hw_checkouts_norm;