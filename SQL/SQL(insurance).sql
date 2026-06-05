USE insurance;
SHOW TABLES;
select * from additional_fields;
select * from claims;
select * from customer_information;
select * from payment_history;
select * from policy_details;

###1 Total number of policies in the system 
select count(policy_Id),status from insurance.policy_details group by status;

###2-Total Customers
select count(customer_id) as Total_Customers from customer_information;

###3 Policies grouped by customer age brackets (e.g., 18-25, 26-35).
select count(customer_id),
	case
		when age between 18 and 25 then '18-25'
        when age between 26 and 35 then '26-35'
        when age between 36 and 45 then '36-45'
        else '45+'
	end as age_bucket from customer_information group by age_bucket;
    
###4 Number of policies categorized by gender (male, female, other).
select c.gender , count(p.policy_id) as policy_count from customer_information c join 
policy_details p on c.Customer_ID=p.Customer_ID group by c.gender order by policy_count desc ;

###5-Policy Type Wise Policy Count
select policy_type,count(policy_id) as Total_policies from policy_details group by policy_type;

###6 Count of policies set to expire within the current calendar year.

set sql_safe_updates=0;
alter table policy_details add col_end_date date;
update policy_details set col_end_date=str_to_date(policy_end_date,'%d-%m-%Y');
select count(policy_id) as POLICY_count,year(col_end_date) as current_year from policy_details where year(col_end_date) =year(now()) group by current_year;

####7 Premium Growth Rate
alter table policy_details add policy_new_start_date date;
set sql_safe_updates=0;
update policy_details set policy_new_start_date=str_to_date(policy_start_date,'%d-%m-%Y');

WITH yearly_premium AS (
    SELECT
        YEAR(Policy_new_Start_Date) AS policy_year,
        SUM(Premium_Amount) AS total_premium
    FROM policy_details
    GROUP BY YEAR(Policy_new_Start_Date)
)
SELECT
    curr.policy_year,
    curr.total_premium AS current_year_premium,
    prev.total_premium AS previous_year_premium,
    ROUND(
        ((curr.total_premium - prev.total_premium) / prev.total_premium) * 100,
        2
    ) AS premium_growth_percentage
FROM yearly_premium curr
LEFT JOIN yearly_premium prev
    ON curr.policy_year = prev.policy_year + 1
ORDER BY curr.policy_year desc;

###8 Claim Status Wise Policy Count
select claim_status,count(policy_id) as Total_policies from claims group by claim_status;
SELECT 
    c.claim_status,
    COUNT(DISTINCT c.policy_id) AS policy_count
FROM claims c
GROUP BY c.claim_status
ORDER BY policy_count DESC;

###9 Payment Status Wise Policy Count
SELECT 
    payment_status,
    COUNT(policy_id) AS policy_count
FROM payment_history
GROUP BY payment_status
ORDER BY policy_count DESC;
select payment_status,count(policy_id) as Total_policies from payment_history group by payment_status;

###10 Total Claim Amount 
select sum(claim_amount) as Total_claim_amount from claims;
SELECT 
    SUM(claim_amount) AS total_claim_amount
FROM  claims
WHERE claim_status = 'Approved';





