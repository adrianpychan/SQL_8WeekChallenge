USE pizza_runner;

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT
    CASE
        WHEN registration_date BETWEEN '2021-01-01' AND '2021-01-07' THEN 'WEEK 1'
        WHEN registration_date BETWEEN '2021-01-08' AND '2021-01-14' THEN 'WEEK 2'
        ELSE 'WEEK 3'
        END as week_registered,
    count(runner_id) as runner_register_count
FROM
    runners
GROUP BY
    week_registered
ORDER BY
    week_registered ASC;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

WITH time_difference AS (
    SELECT
        r.runner_id,
        c.order_time,
        r.pickup_time,
        TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) as minute_difference
    FROM
        customer_orders c
    INNER JOIN
        runner_orders r 
        ON c.order_id = r.order_id
    WHERE
        r.pickup_time != "null"
    GROUP BY
        r.runner_id, c.order_time, r.pickup_time
    ORDER BY
        r.runner_id ASC
)

SELECT
    runner_id,
    ROUND(AVG(minute_difference)) as average_delivery_time
FROM
    time_difference
WHERE
    minute_difference > 1
GROUP BY
    runner_id
ORDER BY
    runner_id ASC;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH order_prep AS (
    SELECT
        c.order_id,
        count(c.order_id) as pizza_count,
        c.order_time,
        r.pickup_time,
        TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) as minute_difference
    FROM
        customer_orders c
    INNER JOIN
        runner_orders r 
        ON c.order_id = r.order_id
    WHERE
        r.pickup_time != "null"
    GROUP BY
        c.order_id, c.order_time, r.pickup_time
    ORDER BY
        pizza_count ASC
)

SELECT
    pizza_count,
    ROUND(AVG(minute_difference), 2) as avg_pizza_time,
    ROUND(ROUND(AVG(minute_difference),1)/pizza_count, 2) as avg_minute_per_pizza
FROM
    order_prep
GROUP BY
    pizza_count;

-- 4. What was the average distance travelled for each customer?

WITH avg_distance_travelled AS (
    SELECT
        c.customer_id,
        CASE
            WHEN r.distance LIKE '%km' THEN SUBSTRING_INDEX(r.distance, "km", 1)
            ELSE r.distance
            END as distance_taken
    FROM
        customer_orders c
    INNER JOIN
        runner_orders r 
        ON c.order_id = r.order_id
    WHERE r.distance != "null"
)

SELECT
    customer_id,
    ROUND(AVG(distance_taken), 2) as avg_distance_per_customer
FROM
    avg_distance_travelled
GROUP BY
    customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?

WITH clean AS (
    SELECT 
        order_id,
        CAST(duration AS DECIMAL) as duration
    FROM
        runner_orders
    WHERE 
        duration != "null"
)

SELECT
    MAX(duration) - MIN(duration) as time_difference
FROM
    clean;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT
    runner_id,
    distance / (duration/60) as avg_km_hour
FROM
    runner_orders
WHERE
    distance != "null" AND duration != "null"
ORDER BY
    runner_id ASC;

-- 7. What is the successful delivery percentage for each runner?

SELECT 
    runner_id,
    ROUND(
        AVG(CASE
            WHEN distance = "null" THEN 0
            ELSE 1
            END) * 100, 2) as avg_delivery_success_rate
FROM 
    runner_orders
GROUP BY 
    runner_id;
