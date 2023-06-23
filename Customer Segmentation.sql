-- Query 1: Highest revenue generating year
SELECT YEAR_ID, SUM(SALES) 
FROM mytable 
GROUP BY YEAR_ID 
ORDER BY SUM(SALES) DESC; -- 2004 is the highest revenue generating year.

-- Query 2: Highest revenue generating month in 2004
SELECT MONTH_ID, SUM(SALES) 
FROM mytable 
WHERE YEAR_ID = 2004
GROUP BY MONTH_ID 
ORDER BY SUM(SALES); -- The month of November is the highest revenue generating month in 2004.

-- Query 3: Best selling product in November 2004
SELECT PRODUCTLINE, SUM(QUANTITYORDERED)
FROM mytable
WHERE MONTH_ID = 11 AND YEAR_ID = 2004 
GROUP BY PRODUCTLINE
ORDER BY SUM(QUANTITYORDERED) DESC; -- Classic cars were the best selling product in November 2004.

-- Query 4: City with the highest number of sales in the US in 2004
SELECT COUNTRY, CITY, SUM(SALES) 
FROM mytable 
WHERE YEAR_ID = 2004 AND COUNTRY = "USA" 
GROUP BY CITY 
ORDER BY SUM(SALES) DESC; -- San Rafael has the highest number of sales in the US in 2004.

-- Query 5: Best selling products in the US by year
SELECT YEAR_ID, PRODUCTLINE, SUM(QUANTITYORDERED) 
FROM mytable 
WHERE COUNTRY = "USA" 
GROUP BY YEAR_ID, PRODUCTLINE 
ORDER BY YEAR_ID, SUM(QUANTITYORDERED) DESC; -- Classic Cars are the best selling products in the US.

-- Query 6: Customer segmentation based on RFM analysis
SELECT
    CUSTOMERNAME,
    Recency,
    Frequency,
    MonetaryValue,
    CASE
        WHEN rfm_recency > 3 AND rfm_frequency > 3 AND rfm_monetary > 3 THEN 'loyal'
        WHEN rfm_recency > 2 AND rfm_frequency > 2 AND rfm_monetary > 2 THEN 'active'
        WHEN rfm_recency > 2 AND rfm_frequency > 1 THEN 'potential churners'
        WHEN rfm_recency > 1 AND rfm_frequency <= 1 THEN 'new customers'
        WHEN rfm_recency <= 2 AND rfm_frequency > 1 THEN 'slipping away, cannot lose'
        ELSE 'lost_customers'
    END AS rfm_segment,
    CASE
        WHEN Frequency > 10 THEN 4
        WHEN Frequency > 6 THEN 3
        WHEN Frequency > 3 THEN 2
        ELSE 1
    END AS FrequencyScore
FROM
    (SELECT
        CUSTOMERNAME,
        DATEDIFF(CURDATE(), DATE_FORMAT(STR_TO_DATE(max(ORDERDATE), '%m/%d/%Y %H:%i'),'%Y-%m-%d')) AS Recency,
        COUNT(ORDERNUMBER) AS Frequency,
        SUM(SALES) AS MonetaryValue,
        NTILE(4) OVER (ORDER BY DATEDIFF(CURDATE(), DATE_FORMAT(STR_TO_DATE(max(ORDERDATE), '%m/%d/%Y %H:%i'),'%Y-%m-%d')) DESC) AS rfm_recency,
        NTILE(4) OVER (ORDER BY COUNT(ORDERNUMBER)) AS rfm_frequency,
        NTILE(4) OVER (ORDER BY SUM(SALES)) AS rfm_monetary
    FROM
        mytable
    GROUP BY
        CUSTOMERNAME) AS rfm_calc;
