
-- a
WITH A_items AS (
    SELECT a.bill_id, a.quantity, b.tech_name 
    FROM bill_item a 
    INNER JOIN items b 
    ON a.item_id = b.item_id
),

A_bill AS (
    SELECT a.bill_id, b.country
    FROM bill a 
    INNER JOIN customer b
    ON a.customer_id = b.customer_id
),

AA_item_bill AS (
    SELECT a.*, b.quantity, b.tech_name
    FROM A_bill a 
    INNER JOIN A_items b 
    ON a.bill_id = b.bill_id
)

SELECT country, SUM(quantity) as quantity
FROM AA_item_bill
WHERE country = 'IT'
AND tech_name LIKE '%Thinkpad%'
GROUP BY 1;

-- a inline
SELECT
    c.country AS customer_country,
    SUM(bi.quantity) AS quantity
FROM bill b
INNER JOIN customer c
    ON b.customer_id = c.customer_id
INNER JOIN bill_item bi
    ON b.bill_id = bi.bill_id
INNER JOIN items i
    ON bi.item_id = i.item_id
WHERE c.country = 'IT'
  AND i.tech_name LIKE '%Thinkpad%'
GROUP BY c.country;

-- aggregation
SELECT b.ref_employee_id, MAX(a.amount) as max_val
FROM bill a 
INNER JOIN ref_employees b
ON a.bill_id = b.bill_id
GROUP BY 1
ORDER BY 2 DESC;

-- subqueries vs with
WITH branch_sales AS (
    SELECT 
        br.branch_id,
        SUM(b.amount) AS total_sales
    FROM branch br
    JOIN bill b ON br.branch_id = b.wh_branch_id
    GROUP BY 1
),
avg_sales AS (
    SELECT AVG(total_sales) AS avg_sales
    FROM branch_sales
)
SELECT 
    e.employee_id,
    e.name,
    e.surname,
    e.role,
    e.department,
    e.branch_id
FROM employees e
JOIN branch_sales bs ON e.branch_id = bs.branch_id
JOIN avg_sales a ON bs.total_sales > a.avg_sales;

-- same query as above but streamlined

SELECT 
    e.employee_id,
    e.name,
    e.surname,
    e.role,
    e.department,
    e.branch_id
FROM employees e
JOIN (
    SELECT 
        a.branch_id,
        SUM(b.amount) AS total_sales
    FROM branch a
    JOIN bill b ON a.branch_id = b.wh_branch_id
    GROUP BY 1
) bs ON e.branch_id = bs.branch_id
WHERE bs.total_sales > (
    SELECT AVG(total_sales)
    FROM (
        SELECT 
            a.branch_id,
            SUM(b.amount) AS total_sales
        FROM branch a
        JOIN bill b ON a.branch_id = b.wh_branch_id
        GROUP BY 1
    ) temp
);
