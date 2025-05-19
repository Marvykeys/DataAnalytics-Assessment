# DataAnalytics-Assessment
## My First Challenge
<p>The first challenge I encountered was trying to figure out which Integrated Development Environment (IDE) to use, so I could load the downloaded database.</p>
I tried using PG Admin and Dbeaver but it proved challenging, after much attempt I tried to find out which SQL syntax the database was created with.
<p>I found that it was a MySQL Syntax. I downloaded MySQL workbench and then I was able to load the database.</p>
<img width="727" alt="COWRYWISE PIC 1" src="https://github.com/user-attachments/assets/60051500-77f1-482d-a87f-b38e36b2d168" />


## Question 1
<p>High-Value Customers with Multiple Products</p>
<p>Scenario:</p> 
The business wants to identify customers who have both a savings and an investment plan (cross-selling opportunity).</p>
<p>Task:</p>
Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.</p>
<p>Tables:</p>

* users_customuser
* savings_savingsaccount
* plans_plan

My Challenge on this question was I initially tried to answer this question with one query but after trying countless times, It still kept on returning headers without rows meaning there was something wrong with my joins or my filtering. 
<p>So I decided to use a FROM Subquery to filter the requirements first then SELECT from the Subquery. This did it for me.</p>
<img width="597" alt="COWRYWISE PIC 2" src="https://github.com/user-attachments/assets/a0dc0008-7930-48ab-be7c-81a37fa1415c" />


#
```python
# Marvellous Eyube selected all the required fields
SELECT
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    sav_invst_subquery.savings_count,
    sav_invst_subquery.investment_count,
    ROUND(SUM(s.confirmed_amount) / 100, 2) AS total_deposits
# Marvellous Eyube created a sub-query to calculate the required criteria
FROM (SELECT
           owner_id,
      SUM(CASE WHEN
               is_regular_savings = 1 THEN 1 ELSE 0 END) AS savings_count,
	  SUM(CASE WHEN
               is_a_fund = 1 THEN 1 ELSE 0 END) AS investment_count
FROM 
	  plans_plan
GROUP BY owner_id) AS sav_invst_subquery
# Marvellous Eyube joined all the tables needed using their PK and FKs
JOIN 
    users_customuser AS u
    ON sav_invst_subquery.owner_id = u.id
JOIN 
    savings_savingsaccount AS s 
    ON u.id = s.owner_id
# Marvellous Eyube grouped the result as required
GROUP BY 
    u.id, u.first_name, u.last_name, 
    sav_invst_subquery.savings_count, sav_invst_subquery.investment_count
# Marvellous Eyube filtered for the customers with both a savings and investment plan
HAVING 
    sav_invst_subquery.savings_count >= 1 
    AND sav_invst_subquery.investment_count >= 1
# Marvellous Eyube sorted by the total deposits from highest to lowest
ORDER BY 
    total_deposits DESC;
```

## Result Sample (First Row)
<img width="626" alt="Quesion 1 screenshot" src="https://github.com/user-attachments/assets/22780471-5f2e-49f7-8873-c7cf111c235b" />


## Question 2
<p>Transaction Frequency Analysis</p>
<p>Scenario:</p> 
The finance team wants to analyze how often customers transact to segment them (e.g., frequent vs. occasional users).</p>
<p>Task:</p>
Calculate the average number of transactions per customer per month and categorize them:</p>

* "High Frequency" (≥10 transactions/month)
* "Medium Frequency" (3-9 transactions/month)
* "Low Frequency" (≤2 transactions/month)

<p>Tables:</p>

* users_customuser
* savings_savingsaccount


#
```python
# Marvellous Eyube created a CTE to retrieve the monthly transactions from the savings account table 
WITH monthly_transactions AS (
    SELECT 
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS month_year,
        COUNT(*) AS transactions_in_month
    FROM savings_savingsaccount
    GROUP BY owner_id, month_year
),
# Marvellous Eyube created another CTE to calculate the average monthly transaction per user
avg_monthly_txn_per_user AS (
    SELECT 
        owner_id,
        AVG(transactions_in_month) AS avg_txn_per_month
    FROM monthly_transactions
    GROUP BY owner_id
),
# Marvellous Eyube created a final CTE to categorize the transaction frequencies
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
# Marvellous Eyube selected the required fields and join the two CTEs I need
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month
FROM avg_monthly_txn_per_user
JOIN categorized_freq USING (owner_id)
GROUP BY frequency_category
ORDER BY 
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
```
# Result Sample (First Row)
<img width="404" alt="Quesion 2 screenshot" src="https://github.com/user-attachments/assets/17069401-0c99-4736-ad57-389c1f7d43b1" />


## Question 3
<p>Account Inactivity Alert</p>
<p>Scenario:</p> 
The ops team wants to flag accounts with no inflow transactions for over one year.</p>
<p>Task:</p>
Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days).</p>
<p>Tables:</p>

* plans_plan
* savings_savingsaccount

#
```python
# Marvellous Eyube selected the required column, using the DATEDIFF function to extract the inactivity days
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
# Marvellous Eyube joined the tables that are needed
JOIN 
    savings_savingsaccount AS s 
    ON p.id = s.plan_id
JOIN
    users_customuser AS u
    ON p.owner_id = u.id
# Marvellous Eyube filtered on the active accounts
WHERE 
    u.is_active = 1
# Marvellous Eyube grouped according to the required output
GROUP BY 
    p.id, p.owner_id, type
# Marvellous Eyube filtered for the inactive days that are more than 365
HAVING 
    DATEDIFF(CURRENT_DATE, last_transaction_date) > 365
# Marvellous Eyube sorted by inactivity days from Highest to Lowest
ORDER BY 
    inactivity_days DESC;
```
# Result Sample (First Row)
<img width="723" alt="Quesion 3 screenshot" src="https://github.com/user-attachments/assets/86888375-7007-4a71-90b3-cd56013bcaa3" />


## Question 4
<p>Customer Lifetime Value (CLV) Estimation</p>
<p>Scenario:</p> 
Marketing wants to estimate CLV based on account tenure and transaction volume (simplified model).</p>
<p>Task:</p>
For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:</p>

* Account tenure (months since signup)
* Total transactions
* Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
* Order by estimated CLV from highest to lowest

<p>Tables:</p>

* users_customuser
* savings_savingsaccount

#
```python
# Marvellous Eyube selected the required fields using some Date/Time and Aggregated functions
SELECT
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    TIMESTAMPDIFF(MONTH, MIN(s.created_on), CURDATE()) AS tenure_months,
    COUNT(CASE WHEN s.transaction_date IS NOT NULL THEN 1 ELSE 0 END) AS total_transactions,
    ROUND((
        (SUM(s.confirmed_amount) / 100) / NULLIF(TIMESTAMPDIFF(MONTH, MIN(s.created_on), CURDATE()), 0)
    ) * 12 * 0.001, 2) AS estimated_clv
# Marvellous Eyube joined the tables needed for the analysis using the PK and FK
FROM 
    users_customuser AS u
JOIN 
    savings_savingsaccount AS s
    ON u.id = s.owner_id
# Marvellous Eyube grouped by the required columns
GROUP BY 
    u.id, u.first_name, u.last_name
# Marvellous Eyube sorted the resulting table by the estimated_clv from Highest to Lowest
ORDER BY 
    estimated_clv DESC;
```
# Result Sample (First Row)
<img width="631" alt="Quesion 4 screenshot" src="https://github.com/user-attachments/assets/cc56edb8-58cb-45a4-ab03-1f2a92600cb2" />

# THANK YOU COWRYWISE!!! ❤️🙋‍♂️



