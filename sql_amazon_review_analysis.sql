-- Settings up tables for review analysis
SELECT *
INTO total_votes_filtered
FROM vine_table
WHERE total_votes >=20;

SELECT *
INTO helpful_votes_above_50
FROM total_votes_filtered
WHERE CAST(helpful_votes AS float)/CAST(total_votes AS float) >=0.5;

SELECT * 
INTO paid_reviews
FROM helpful_votes_over_50
WHERE vine = 'Y';

SELECT * 
INTO unpaid_reviews
FROM helpful_votes_over_50
WHERE vine = 'N';

-- Tables to hold paid reviews with 5 stars

-- Table for count of total paid reviews
CREATE TABLE total_paid_reviews (
    total_reviews int);
	
-- Table for count of total paid 5 star reviews
CREATE TABLE five_star_paid_reviews (
    total_5_star_reviews int);

-- Insert the count of total paid reviews into its table
INSERT TABLE total_paid_reviews(total_reviews) 
SELECT COUNT(total_votes) 
FROM paid_reviews;

-- Insert count of total paid 5 star reviews into its table
INSERT INTO five_star_paid_reviews(total_5_star_reviews) 
SELECT COUNT(star_rating)
FROM paid_reviews
WHERE star_rating= 5;

-- Insert total paid reviews and total 5 star reviews into a temporary table
SELECT tpr.total_reviews, fspr.total_5_star_reviews
INTO paid_review_temp
FROM total_paid_reviews as tpr
INNER JOIN five_star_paid_reviews as fspr ON 1 = 1;

-- Insert total paid reviews and total 5 star reviews columns and 
-- calculate the percentage of total 5 star reviews and insert all into new table
SELECT total_reviews, total_5_star_reviews,
	CAST(total_5_star_reviews AS FLOAT)/ CAST(total_reviews AS FLOAT)*100 AS percent_five_star 
INTO paid_review_analysis
FROM paid_review_temp;

SELECT * FROM paid_review_analysis;


-- Repeat the process above for all unpaid reviews. 

CREATE TABLE total_unpaid_reviews (
    total_reviews int);
	
CREATE TABLE five_star_unpaid_reviews (
    total_5_star_reviews int);

INSERT INTO total_unpaid_reviews(total_reviews) 
SELECT COUNT(total_votes) 
FROM unpaid_reviews;

INSERT INTO five_star_unpaid_reviews(total_5_star_reviews) 
SELECT COUNT(star_rating)
FROM unpaid_reviews
WHERE star_rating= 5;

SELECT tupr.total_reviews, fsupr.total_5_star_reviews
INTO unpaid_review_temp
FROM total_unpaid_reviews as tupr
INNER JOIN five_star_unpaid_reviews as fsupr ON 1 = 1;

SELECT total_reviews, total_5_star_reviews,
	CAST(total_5_star_reviews AS FLOAT)/ CAST(total_reviews AS FLOAT)*100 AS percent_five_star 
INTO unpaid_review_analysis
FROM unpaid_review_temp;

SELECT * FROM unpaid_review_analysis;