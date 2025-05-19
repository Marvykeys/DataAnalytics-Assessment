-- Marvellous Eyube selected all the required fields
SELECT
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    sav_invst_subquery.savings_count,
    sav_invst_subquery.investment_count,
    ROUND(SUM(s.confirmed_amount) / 100, 2) AS total_deposits
-- Marvellous Eyube created a sub-query to calculate the required criteria
FROM (SELECT
           owner_id,
      SUM(CASE WHEN
               is_regular_savings = 1 THEN 1 ELSE 0 END) AS savings_count,
	  SUM(CASE WHEN
               is_a_fund = 1 THEN 1 ELSE 0 END) AS investment_count
FROM 
	  plans_plan
GROUP BY owner_id) AS sav_invst_subquery
-- Marvellous Eyube joined all the tables needed using their PK and FKs
JOIN 
    users_customuser AS u
    ON sav_invst_subquery.owner_id = u.id
JOIN 
    savings_savingsaccount AS s 
    ON u.id = s.owner_id
-- Marvellous Eyube grouped the result as required
GROUP BY 
    u.id, u.first_name, u.last_name, 
    sav_invst_subquery.savings_count, sav_invst_subquery.investment_count
-- Marvellous Eyube filtered for the customers with both a savings and investment plan
HAVING 
    sav_invst_subquery.savings_count >= 1 
    AND sav_invst_subquery.investment_count >= 1
-- Marvellous Eyube sorted by the total deposits from highest to lowest
ORDER BY 
    total_deposits DESC;