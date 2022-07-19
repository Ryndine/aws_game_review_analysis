# Amazon Game Reviews Analysis

## Objective: 
Utilize cloud tools to create database, storage, and run analysis on amazon reviews.

## Tools & databases used:
- Spark, SQL, AWS, RDS, S3, PostgresSQL. JDBC, HDFS, pgAdmin

## ETL:

**AWS Setup**
- Create a new RDS for project
  - Created with public access
  - Setup Security group rules
  - PostgreSQL database

![aws_database](/Resources/Images/aws_database.jpg)

- Create a new Bucket for project
  - Enable ACLs
  - Modify access of bucket
  - Upload data and make it readable for importing into project
  
![s3_data_upload](/Resources/Images/s3_data_upload.jpg)

**Google Colab Setup**

- Setup Google Colab  
![gcolab_setup](/Resources/Images/gcolab_setup.jpg)

- Create spark session builder and load in amazon data from S3  
```
# Spark
spark = SparkSession.builder.appName("AWS-Amazon-Reviews").config("spark.driver.extraClassPath","/content/postgresql-42.2.16.jar").getOrCreate()
# Get files
url = "https://s3.amazonaws.com/amazon-reviews-pds/tsv/amazon_reviews_us_Digital_Video_Games_v1_00.tsv.gz"
spark.sparkContext.addFile(url)
df = spark.read.csv(SparkFiles.get("amazon_reviews_us_Digital_Video_Games_v1_00.tsv.gz"), sep="\t", header=True, inferSchema=True)
df.show()
```
**Spark**

- Review ID Table  
```
review_id_df = df.select(["review_id", "customer_id", "product_id", "product_parent", to_date("review_date", 'yyyy-MM-dd').alias("review_date")])
```
![review_table](/Resources/Images/review_id_table.jpg)

- Product ID Table  
```
products_df = df.select(["product_id", "product_title"])
products_df = df.select(["product_id", "product_title"]).drop_duplicates()
```
![product_id_table](/Resources/Images/product_id_table.jpg)

- Customer Table  
```
customers_df = df.groupby("customer_id").agg({"customer_id": "count"}).withColumnRenamed("count(customer_id)", "customer_count")
```
![customer_table](/Resources/Images/customer_table.jpg)

- Vine Table  
```
vine_df = df.select(["review_id", "star_rating", "helpful_votes", "total_votes", "vine", 'verified_purchase'])
```
![vine_table](/Resources/Images/vine_table.jpg)

**Database**

- Create schema for data  
```
CREATE TABLE review_id_table (
  review_id TEXT PRIMARY KEY NOT NULL,
  customer_id INTEGER,
  product_id TEXT,
  product_parent INTEGER,
  review_date DATE
);
CREATE TABLE products_table (
  product_id TEXT PRIMARY KEY NOT NULL UNIQUE,
  product_title TEXT
);
CREATE TABLE customers_table (
  customer_id INT PRIMARY KEY NOT NULL UNIQUE,
  customer_count INT
);
CREATE TABLE vine_table (
  review_id TEXT PRIMARY KEY,
  star_rating INTEGER,
  helpful_votes INTEGER,
  total_votes INTEGER,
  vine TEXT,
  verified_purchase TEXT
);
```

- Use JDBC to write spark data to AWS database.  
```
from config import aws_db_conn, aws_username, aws_password
# Configure settings for RDS
mode = "append"
jdbc_url="aws_db_conn"
config = {"user":"aws_username", 
          "password": "aws_password", 
          "driver":"org.postgresql.Driver"}
```
```
# Write review_id_df to the table in RDS
review_id_df.write.jdbc(url=jdbc_url, table='review_id_table', mode=mode, properties=config)
# Write products_df to the table in RDS
products_df.write.jdbc(url=jdbc_url, table='products_table', mode=mode, properties=config)
# Write customers_df to the table in RDS
customers_df.write.jdbc(url=jdbc_url, table='customers_table', mode=mode, properties=config)
# Write vine_df to the table in RDS
vine_df.write.jdbc(url=jdbc_url, table='vine_table', mode=mode, properties=config)
```

**Analysis**
- Explore data for bias
