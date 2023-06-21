-- Total Customer Churn Rate: What is the overall churn rate for all customers?
SELECT 
	COUNT(CASE WHEN churn = 1 THEN 1 END) / COUNT(*) * 100 AS churnedCustomers_PCT,
	COUNT(CASE WHEN churn = 0 THEN 1 END) / COUNT(*) * 100 AS notChurnedCustomers_PCT
FROM CustomerChurn.Customer;

-- Churn Rate by Country: Which countries have the highest churn rates?
WITH churnRate AS (
	SELECT 
		country,
		COUNT(CASE WHEN churn = 1 THEN 1 END) / COUNT(*) * 100 AS churnedCustomers_PCT,
		COUNT(CASE WHEN churn = 0 THEN 1 END) / COUNT(*) * 100 AS notChurnedCustomers_PCT
	FROM CustomerChurn.Customer 
    GROUP BY country
)
SELECT *,
	RANK() OVER(
		ORDER BY churnRate.churnedCustomers_PCT DESC
    ) AS 'RankByChurnedCustomers' 
FROM churnRate;

-- Churn Rate by Age Group: What is the churn rate distribution across different age groups?
WITH churnRate AS (
	SELECT 
		FLOOR(age/5) * 5 AS ageGroup,
		COUNT(CASE WHEN churn = 1 THEN 1 END) / COUNT(*) * 100 AS churnedCustomers_PCT,
		COUNT(CASE WHEN churn = 0 THEN 1 END) / COUNT(*) * 100 AS notChurnedCustomers_PCT
	FROM CustomerChurn.Customer 
    GROUP BY ageGroup
    HAVING COUNT(ageGroup) >= 5 -- Some age group contain only a few samples (less than 3)
)
SELECT *,
	NTILE(4) OVER(
		ORDER BY notChurnedCustomers_PCT DESC
    ) AS 'Quartile' 
FROM churnRate;

-- Churn Rate by Gender: How does the churn rate vary between different genders?
WITH churnRate AS (
	SELECT 
		gender,
		COUNT(CASE WHEN churn = 1 THEN 1 END) / COUNT(*) * 100 AS churnedCustomers_PCT,
		COUNT(CASE WHEN churn = 0 THEN 1 END) / COUNT(*) * 100 AS notChurnedCustomers_PCT
	FROM CustomerChurn.Customer 
    GROUP BY gender
)
SELECT *,
	RANK() OVER(
		ORDER BY churnRate.churnedCustomers_PCT DESC
    ) AS 'RankByChurnedCustomers' 
FROM churnRate;

-- Churn Rate by Gender and Age Group: Is there a significant difference in churn rates when considering both gender and age group? 	
-- Gender / ageGroup
WITH subQ AS(
	SELECT *,
		CASE 
			WHEN Age < 18 THEN 'Under 18'
            WHEN Age >= 18 AND Age < 25 THEN '18-24'
            WHEN Age >= 25 AND Age < 35 THEN '25-34'
            WHEN Age >= 35 AND Age < 45 THEN '35-44'
            WHEN Age >= 45 AND Age < 55 THEN '45-54'
            WHEN Age >= 55 AND Age < 65 THEN '55-64'
            ELSE '65+'
		END AS AgeGroup
	FROM CustomerChurn.Customer 
)
SELECT 
	AgeGroup, 
	gender,  
	100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY AgeGroup) AS GenderPCT,
	100.0 * COUNT(CASE WHEN churn = 1 THEN 1 END) / COUNT(*) AS churnedCustomersPCT
FROM subQ
GROUP BY AgeGroup, gender; 

-- Country / ageGroup
WITH subQ AS(
	SELECT *,
		CASE 
			WHEN Age < 18 THEN 'Under 18'
            WHEN Age >= 18 AND Age < 25 THEN '18-24'
            WHEN Age >= 25 AND Age < 35 THEN '25-34'
            WHEN Age >= 35 AND Age < 45 THEN '35-44'
            WHEN Age >= 45 AND Age < 55 THEN '45-54'
            WHEN Age >= 55 AND Age < 65 THEN '55-64'
            ELSE '65+'
		END AS AgeGroup
	FROM CustomerChurn.Customer 
)
SELECT 
	AgeGroup, 
	country,  
	100.0 * COUNT(CASE WHEN churn = 1 THEN 1 END) / COUNT(*) AS churnedCustomersPCT
FROM subQ
GROUP BY AgeGroup, country
ORDER BY AgeGroup, country;

-- Average Credit Score by Gender: What is the average credit score of customers based on their gender?
SELECT gender, AVG(credit_score) AS 'Average_credit_score'
From customerChurn.Customer
GROUP BY gender; 

-- Ranking Total Balance by Country: How do countries rank in terms of the total balance of their customers?
SELECT 
	country, 
	SUM(balance) AS total_balance,
    RANK() OVER (
        ORDER BY SUM(balance) DESC
    ) AS 'Ranking'
FROM customerChurn.Customer
GROUP BY country;

-- Active and Inactive Members by Country: How many members are active and inactive in each country?
SELECT 
	country,
    SUM(CASE WHEN active_member = 1 THEN 1 ELSE 0 END) AS 'activeMembers',
	SUM(CASE WHEN active_member = 0 THEN 1 ELSE 0 END) AS 'inactiveMembers'
FROM customerChurn.Customer
GROUP BY country;

-- Average Salary of Customers in Each Age Group: What is the average salary of customers in different age groups?
SELECT 
	FLOOR(age/10) * 10 AS ageGroup,
    ROUND(AVG(estimated_salary),2)
FROM customerChurn.Customer
GROUP BY ageGroup
ORDER BY ageGroup;



