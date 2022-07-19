# Amazon Game Reviews Analysis

## Objective: 
Utilize cloud tools to create database, storage, and run analysis on amazon reviews.

## Tools & databases used:
- Spark, SQL, AWS, RDS, S3, PostgresSQL. JDBC, HDFS, pgAdmin

## Analysis:

**Setup**
- Setup Google Colab
- Create spark session builder and load in amazon data from S3

**Create tables for postgresql**
- Spark manipulations on data
- Table to show information on reviews
- Table for the games being reviewed
- Table showing how many reviews a customer has made
- Table showing the rating for the review, vine members, and verfication.

**Setup AWS RDS**
- Create RDS, setup PostgreSQL database, connect pgAdmin to database.
- Create schema for data
- Use JDBC to write spark data to AWS database.

**Analysis**