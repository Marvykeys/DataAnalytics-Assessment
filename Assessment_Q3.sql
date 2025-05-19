-- Marvellous Eyube selected the required column, using the DATEDIFF function to extract the inactivity days
SELECT
    p.id AS plan_id,
    p.owner_id,
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Other'
    END AS type,
    MAX(s.created_on) AS last_transaction_date,
    DATEDIFF(CURRENT_DATE, MAX(s.created_on)) AS inactivity_days
FROM 
    plans_plan AS p
-- Marvellous Eyube joined the tables that are needed
JOIN 
    savings_savingsaccount AS s 
    ON p.id = s.plan_id
JOIN
    users_customuser AS u
    ON p.owner_id = u.id
-- Marvellous Eyube filtered on the active accounts
WHERE 
    u.is_active = 1
-- Marvellous Eyube grouped according to the required output
GROUP BY 
    p.id, p.owner_id, type
-- Marvellous Eyube filtered for the inactive days that are more than 365
HAVING 
    DATEDIFF(CURRENT_DATE, last_transaction_date) > 365
-- Marvellous Eyube sorted by inactivity days from Highest to Lowest
ORDER BY 
    inactivity_days DESC;