-- 1. How many pizzas were ordered?

SELECT
    count(order_id)
FROM 
    customer_orders;

-- 2. How many unique customer orders were made?

SELECT
    COUNT(DISTINCT(order_id))
FROM
    customer_orders;

-- 3. How many successful orders were delivered by each runner?

SELECT
    COUNT(duration) 
FROM
    runner_orders
WHERE
    duration != "null"

-- 4. How many of each type of pizza was delivered?

SELECT
    pizza_id,
    count(pizza_id)
FROM
    customer_orders
GROUP BY
    pizza_id;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
    pizza_names.pizza_name,
    customer_orders.customer_id,
    COUNT(customer_orders.pizza_id) as order_count
FROM
    customer_orders
INNER JOIN
    pizza_names 
    ON customer_orders.pizza_id = pizza_names.pizza_id
GROUP BY
    customer_orders.pizza_id, customer_orders.customer_id, pizza_names.pizza_name
ORDER BY
   customer_orders.customer_id ASC;

-- 6. What was the maximum number of pizzas delivered in a single order?

SELECT
    co.order_id,
    COUNT(co.pizza_id) as total_orders_per_order
FROM
    customer_orders co
GROUP BY
    co.order_id
ORDER BY
    total_orders_per_order DESC;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT
    customer_id,
    SUM(CASE
        WHEN (
            (exclusions IS NOT NULL AND exclusions <> "null" AND LENGTH(exclusions) > 0) -- NULL = No changes made
            OR (extras IS NOT NULL and extras <> "null" AND LENGTH(extras) > 0)
            ) = TRUE
        THEN 1
        ELSE 0
        END) as one_change_made,
    SUM(CASE
        WHEN (
            (exclusions IS NOT NULL AND exclusions <> "null" AND LENGTH(exclusions) > 0) -- NULL = No changes made
            OR (extras IS NOT NULL and extras <> "null" AND LENGTH(extras) > 0)
            ) = TRUE
        THEN 0
        ELSE 1
        END) as no_changes_made
FROM
    customer_orders
INNER JOIN
    runner_orders ON customer_orders.order_id = runner_orders.order_id
WHERE
    runner_orders.pickup_time <> "null"
GROUP BY
    customer_id
ORDER BY
    customer_id ASC;

-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT
    count(pizza_id) as both_changes_made
FROM
    customer_orders
INNER JOIN
    runner_orders ON customer_orders.order_id = runner_orders.order_id
WHERE
    runner_orders.pickup_time <> "null" 
    AND (exclusions IS NOT NULL AND exclusions <> "null" AND LENGTH(exclusions) > 0) -- NULL = No changes made
    AND (extras IS NOT NULL and extras <> "null" AND LENGTH(extras) > 0);

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT
    hour(order_time) as hour,
    COUNT(*) as pizza_order_volume
FROM
    customer_orders
GROUP BY
    hour
ORDER BY
    hour, pizza_order_volume ASC;

-- 10. What was the volume of orders for each day of the week?

SELECT
    DAYNAME(order_time) as day_name,
    COUNT(*) as pizza_order_volume
FROM
    customer_orders
GROUP BY
    day_name
ORDER BY
    pizza_order_volume DESC;
