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

# Result Sample (First Row)
<table>
    <thead>
        <tr>
            <th>owner_id</th>
            <th>name</th>
            <th>savings_count</th>
            <th>investment_count</th>
            <th>total_deposits</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>1909df3eba2548cfa3b9c270112bd262</td>
            <td>Chima Ataman</td>
            <td>3</td>
            <td>9</td>
            <td>890312215.48</td>
        </tr>



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
<table>
    <thead>
        <tr>
            <th>frequency_category</th>
            <th>customer_count</th>
            <th>avg_transactions_per_month</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>High Frequency</td>
            <td>141</td>
            <td>44.7</td>
        </tr>

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
<table>
    <thead>
        <tr>
            <th>plan_id</th>
            <th>owner_id</th>
            <th>type</th>
            <th>last_transaction_date</th>
            <th>inactivity_days</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>ba6cda07fcd44c6a812fb0b7fee01b3c</td>
            <td>0257625a02344b239b41e1cbe60ef080</td>
            <td>Savings</td>
            <td>2016-09-18 19:07:14</td>
            <td>3164</td>
        </tr>


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
<table>
    <thead>
        <tr>
            <th>customer_id</th>
            <th>name</th>
            <th>tenure_months</th>
            <th>total_transactions</th>
            <th>estimated_clv</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>1909df3eba2548cfa3b9c270112bd262'</td>
            <td>Chima Ataman</td>
            <td>28</td>
            <td>2383</td>
            <td>381562.38</td>
        </tr>
