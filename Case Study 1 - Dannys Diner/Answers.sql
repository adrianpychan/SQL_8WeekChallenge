-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, sum(m.price) as total_spent 
FROM sales s
INNER JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id 
ORDER BY s.customer_id ASC;

-- 2. How many days has each customer visited the restaurant?

SELECT s1.customer_id, count(DISTINCT s1.order_date) as visit_count
FROM dannys_diner.sales as S1
GROUP BY s1.customer_id
ORDER BY s1.customer_id ASC;

-- 3. What was the first item from the menu purchased by each customer?

WITH LOL as (
    SELECT 
        s.customer_id, 
        s.order_date, 
        m.product_name,
        RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) as ranking
    FROM sales AS s
    INNER JOIN menu m
    ON s.product_id = m.product_id)

SELECT *
FROM LOL
WHERE ranking = 1
ORDER BY ranking ASC;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
    m.product_name,
    count(m.product_name) as total_purchase
FROM 
    menu m
INNER JOIN 
    sales s ON m.product_id = s.product_id
GROUP BY 
    m.product_name
ORDER BY 
    total_purchase DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

WITH popular as (
    SELECT
        m.product_name,
        s.customer_id,
        count(m.product_name) as purchase_frequency,
        RANK() OVER (PARTITION BY s.customer_id ORDER BY count(m.product_name) DESC) as purchase_ranking
    FROM
        sales s
    INNER JOIN
        menu m 
        ON s.product_id = m.product_id
    GROUP BY
        s.customer_id, m.product_name
    ORDER BY
        purchase_ranking ASC, customer_id ASC, purchase_frequency DESC
)

SELECT product_name,
    customer_id,
    purchase_frequency
FROM popular
WHERE purchase_ranking = "1"
ORDER BY customer_id,
    purchase_frequency ASC;

-- 6. Which item was purchased first by the customer after they became a member?

WITH member_first AS (
    SELECT 
        s.customer_id,
        m.product_name,
        s.order_date,
        members.join_date,
        RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) as ranking
    FROM
        sales s
    INNER JOIN 
        members 
        ON s.customer_id = members.customer_id
    INNER JOIN
        menu m
        ON s.product_id = m.product_id
    WHERE s.order_date >= members.join_date
)

SELECT 
    customer_id,
    product_name,
    order_date,
    join_date
FROM 
    member_first
WHERE 
    ranking = 1
ORDER BY 
    customer_id,
    order_date,
    join_date ASC;

-- 7. Which item was purchased just before the customer became a member?

WITH before_m AS (
    SELECT 
        s.customer_id,
        m.product_name,
        s.order_date,
        members.join_date,
        RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) as ranking
    FROM
        sales s
    INNER JOIN 
        members 
        ON s.customer_id = members.customer_id
    INNER JOIN
        menu m
        ON s.product_id = m.product_id
    WHERE 
        s.order_date < members.join_date
    ORDER BY 
        s.customer_id, 
        s.order_date, 
        members.join_date ASC
)

SELECT
    customer_id,
    product_name,
    order_date,
    join_date
FROM before_m
WHERE ranking = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT
    s.customer_id,
    COUNT(m.product_name) as total_items,
    SUM(m.price) as total_spent
FROM
    sales s
INNER JOIN
    members MEM
    ON s.customer_id = MEM.customer_id
INNER JOIN
    menu m
    ON s.product_id = m.product_id
WHERE 
    s.order_date < MEM.join_date
GROUP BY
    s.customer_id
ORDER BY
    s.customer_id ASC;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT
    s.customer_id,
    SUM(
    CASE WHEN m.product_name = 'sushi' -- Conditional Statement
        THEN m.price * 10 * 2
        ELSE price * 10 END) as points
FROM
    menu m
INNER JOIN
    sales s ON m.product_id = s.product_id
WHERE s.customer_id = "A" or s.customer_id = "B"
GROUP BY
    s.customer_id
ORDER BY
    customer_id ASC;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- Checking:
SELECT s.customer_id,
    CASE
        WHEN s.order_date BETWEEN MEM.join_date AND DATE_ADD(MEM.join_date, INTERVAL 6 DAY) THEN price * 10 * 2 -- Conditional Statement
        WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
        ELSE price * 10
    END as points,
    s.order_date,
    MEM.join_date
FROM menu m
    INNER JOIN sales s ON m.product_id = s.product_id
    INNER JOIN members MEM on s.customer_id = MEM.customer_id
WHERE MONTH(s.order_date) = 1
ORDER BY s.customer_id,
    s.order_date,
    MEM.join_date ASC;

-- Answer:
SELECT s.customer_id,
    SUM(
        CASE
            WHEN s.order_date BETWEEN MEM.join_date AND DATE_ADD(MEM.join_date, INTERVAL 6 DAY) THEN price * 10 * 2 -- Conditional Statement
            WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
            ELSE price * 10
        END) as points
FROM menu m
    INNER JOIN sales s ON m.product_id = s.product_id
    INNER JOIN members MEM on s.customer_id = MEM.customer_id
WHERE MONTH(s.order_date) = 1
GROUP BY s.customer_id
ORDER BY s.customer_id ASC;

