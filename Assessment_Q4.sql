-- Marvellous Eyube selected the required fields using some Date/Time and Aggregated functions
SELECT
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    TIMESTAMPDIFF(MONTH, MIN(s.created_on), CURDATE()) AS tenure_months,
    COUNT(CASE WHEN s.transaction_date IS NOT NULL THEN 1 ELSE 0 END) AS total_transactions,
    ROUND((
        (SUM(s.confirmed_amount) / 100) / NULLIF(TIMESTAMPDIFF(MONTH, MIN(s.created_on), CURDATE()), 0)
    ) * 12 * 0.001, 2) AS estimated_clv
-- Marvellous Eyube joined the tables needed for the analysis using the PK and FK
FROM 
    users_customuser AS u
JOIN 
    savings_savingsaccount AS s
    ON u.id = s.owner_id
-- Marvellous Eyube grouped by the required columns
GROUP BY 
    u.id, u.first_name, u.last_name
-- Marvellous Eyube sorted the resulting table by the estimated_clv from Highest to Lowest
ORDER BY 
    estimated_clv DESC;