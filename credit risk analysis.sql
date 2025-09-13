-- Total loans, outstanding principal, average credit score
SELECT 
    COUNT(DISTINCT L.loan_id) AS total_loans,
    ROUND(SUM(L.amount),2) AS total_loan_amount,
    ROUND(AVG(C.credit_score),0) AS avg_credit_score,
    ROUND(1.0 * SUM(CASE WHEN L.status = 'Defaulted' THEN 1 ELSE 0 END) / COUNT(*),2) AS default_rate
FROM Loans L
JOIN Customers C ON L.customer_id = C.customer_id;

-- Track defaults by payment year (using Payments table)
SELECT 
    EXTRACT(YEAR FROM P.payment_date) AS pay_year,
    SUM(CASE WHEN L.status = 'Defaulted' THEN 1 ELSE 0 END) AS defaulted_loans,
    COUNT(DISTINCT L.loan_id) AS total_loans
FROM Loans L
JOIN Payments P ON L.loan_id = P.loan_id
GROUP BY pay_year
ORDER BY pay_year;


-- Default probability by credit score band
SELECT
    CASE 
        WHEN C.credit_score < 600 THEN '<600'
        WHEN C.credit_score BETWEEN 600 AND 699 THEN '600-699'
        WHEN C.credit_score BETWEEN 700 AND 749 THEN '700-749'
        ELSE '750+' END AS score_band,
    COUNT(L.loan_id) AS total_loans,
    SUM(CASE WHEN L.status = 'Defaulted' THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(100.0 * SUM(CASE WHEN L.status = 'Defaulted' THEN 1 ELSE 0 END) / COUNT(L.loan_id),2) AS pd_percent
FROM Loans L
JOIN Customers C ON L.customer_id = C.customer_id
GROUP BY score_band
ORDER BY score_band;

-- Default rates by city
SELECT 
    C.city,
    COUNT(L.loan_id) AS total_loans,
    SUM(CASE WHEN L.status = 'Defaulted' THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(100.0 * SUM(CASE WHEN L.status = 'Defaulted' THEN 1 ELSE 0 END) / COUNT(L.loan_id),2) AS default_rate
FROM Customers C
JOIN Loans L ON C.customer_id = L.customer_id
GROUP BY C.city
ORDER BY default_rate DESC
LIMIT 10;

-- Risk exposure by loan type
SELECT 
    L.loan_type,
    COUNT(L.loan_id) AS total_loans,
    SUM(CASE WHEN L.status = 'Defaulted' THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(1.0 * SUM(CASE WHEN L.status = 'Defaulted' THEN 1 ELSE 0 END) / COUNT(L.loan_id),2) AS default_rate
FROM Loans L
GROUP BY L.loan_type
ORDER BY default_rate DESC;

