-- Marvellous Eyube created a CTE to retrieve the monthly transactions from the savings account table 
WITH monthly_transactions AS (
    SELECT 
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS month_year,
        COUNT(*) AS transactions_in_month
    FROM savings_savingsaccount
    GROUP BY owner_id, month_year
),
-- Marvellous Eyube created another CTE to calculate the average monthly transaction per user
avg_monthly_txn_per_user AS (
    SELECT 
        owner_id,
        AVG(transactions_in_month) AS avg_txn_per_month
    FROM monthly_transactions
    GROUP BY owner_id
),
-- Marvellous Eyube created a final CTE to categorize the transaction frequencies
categorized_freq AS (
    SELECT 
        owner_id,
        CASE 
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txn_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM avg_monthly_txn_per_user
)
-- Marvellous Eyube selected the required fields and join the two CTEs I need
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month
FROM avg_monthly_txn_per_user
JOIN categorized_freq USING (owner_id)
GROUP BY frequency_category
ORDER BY 
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');