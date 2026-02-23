-- Customer Segmentation: Gold / Silver / Bronze
-- Option A: Fixed thresholds (adjust thresholds as business requires)
WITH customer_spend AS (
    SELECT c.customer_id,
           c.name,
           SUM(COALESCE(o.order_amount,0) - COALESCE(o.discount,0)) AS total_spent,
           COUNT(*) AS orders_count
    FROM Orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.name
)
SELECT customer_id,
       name,
       total_spent,
       orders_count,
       CASE
         WHEN total_spent >= 1000 THEN 'Gold'
         WHEN total_spent >= 500  THEN 'Silver'
         ELSE 'Bronze'
       END AS category
FROM customer_spend
ORDER BY total_spent DESC;

-- Option B: Quantile-based segmentation (equal-sized groups)
SELECT customer_id,
       name,
       total_spent,
       CASE tier
         WHEN 1 THEN 'Gold'
         WHEN 2 THEN 'Silver'
         ELSE 'Bronze'
       END AS category
FROM (
  SELECT c.customer_id,
         c.name,
         SUM(COALESCE(o.order_amount,0) - COALESCE(o.discount,0)) AS total_spent,
         NTILE(3) OVER (ORDER BY SUM(COALESCE(o.order_amount,0) - COALESCE(o.discount,0)) DESC) AS tier
  FROM Orders o
  JOIN customers c ON o.customer_id = c.customer_id
  GROUP BY c.customer_id, c.name
) t
ORDER BY total_spent DESC;
