#data types

**Primitive data types**
-------------------------
1.Boolean - TRUE/FALSE
2.Numeric - Integer(INT,BIGINT),Decimal(float,double)
3.String - Char(fixed length),varchar(variable length)
4.Timestamp - date with Timestamp

**Collection**
--------------
1.Array - List of data with same data type. Supports only Primitive data types.
	def : PRODUCT_CATEGORY ARRAY<VARCHAR(1000)>

2.Map - key value pairs. Key and Value can be different data types.
	def : DICTIONARY MAP<STRING, ARRAY<VARCHAR(1000)>>

3.Struct - a group of variables with different data types.
	def : STUDENT STRUCT<ID:INT,NAME:VARCHAR(1000),TUITION_FEES:FLOAT>

4.Union - a column can be of any datatype specified. One record can be only data type at a time.
	def : LAUNCH_DATE UNIONTYPE<TIMESTAMP,VARCHAR(1000)>


**Tables**
-----------
1.Managed - Hive manages both data and metastore information. When table is dropped the data is deleted from HDFS(including directory).
	Note: by default all tables are managed

2.External - Hive manages only the metastore information. When table is dropped, data is untouched. Used when other programs such as Pig,HBASE uses same source data. Specify the location where the data will be stored.
	def : CREATE EXTERNAL TABLE IDENTITY(ID INT) 
		  LOCATION '/user/mohan'

3. Temporary - Exists for a session and dropped automatically once session is closed. Used to hold data temporarily.
	def : CREATE TEMPORARY TABLE IDENTITY_TEMP(ID INT)


#show databases
show databases ;

#select database
use default ;

#schema details
describe sample_07 ;

#extended schema details
describe extended sample_07;

#show tables
SHOW TABLES;

#Show create table query
SHOW CREATE TABLE EMPLOYEE;

#select statement
select * from sample_07 ;

from sample_07 select * ; #this works as well


**CREATING TABLES**
-------------------
#internal table

CREATE TABLE EMPLOYEE 
(
	EMP_ID INT,
	EMP_NAME VARCHAR(100),
	EMP_DEPT VARCHAR(100),
	EMP_DESG VARCHAR(50),
	GENDER VARCHAR(10),
	SALARY BIGINT,
	ADDRESS MAP<STRING,STRING>
) 

ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
COLLECTION ITEMS TERMINATED BY ','
MAP KEYS TERMINATED BY ':';

--sample data
1|MOHANRAM KRISHNAN|IT|DATA SCIENTIST|M|100000|CITY:Chennai,ZIP:600100
2|MANOJ|IT|DEVELOPER|M|200000|CITY:Madurai,ZIP:600100


insert into employee select 1,'MURALI','MECH','DATA SCIENTIST','M',500000,map("CITY","Chennai","ZIP",600100) from sales_data limit 1; --if limit clause is omitted as many rows will be inserted as we have in sales_data table.

LOCATION '/user/mohan/employee'; #by default table directories are created under ware house.

Note: hive.metastore.warehouse.dir is the property to be set to change default hive warehouse directory.

SET hive.metastore.warehouse.dir = 'user/hive/warehouse';

#creating table from existing table
CREATE TABLE EMPLOYEE_COPY IF NOT EXISTS
like EMPLOYEE;

#creating table with data
CREATE TABLE EMPLOYEE_COPY IF NOT EXISTS
AS SELECT * FROM EMPLOYEE; #a file copy of employee data is placed under newly create table directory in hdfs.



**INSERT INTO TABLES**
----------------------
#one row at a time

INSERT INTO EMPLOYEE
VALUES
(1,'MOHANRAM KRISHNAN','IT','DATA SCIENTIST','M','100000');

#Multiple row at a time
INSERT INTO EMPLOYEE 
VALUES
(2,'ANJALI','FINANCE','MANAGER','F','200000'),
(3,'ARUN C R','IT','DEVELOPER','M','300000');


#inserting data from existing table
INSERT OVERWRITE TABLE EMPLOYEE_COPY
SELECT * FROM EMPLOYEE;

#inserting into multiple tables from existing table
FROM EMPLOYEE
INSERT OVERWRITE TABLE EMPLOYEE_COPY
SELECT *
INSERT OVERWRITE TABLE EMPLOYEE_COPY2
SELECT *



#loading table from a file from local path
LOAD DATA LOCAL INPATH '/user/hive/employee.txt' overwrite into table employee; #overwrite overwrites the record in table. if omitted, the data is appended.




**ALTERING TABLES**
--------------------

#Change table name
ALTER TABLE EMPLOYEE EMPLOYEE_RENAMED;

#Add columns
ALTER TABLE EMPLOYEE ADD COLUMNS(SHIFT VARCHAR(50));

#Delete Columns
ALTER TABLE EMPLOYEE REPLACE COLUMNS(EMP_ID INT,
	EMP_NAME VARCHAR(100),
	EMP_DEPT VARCHAR(100),
	EMP_DESG VARCHAR(50),
	GENDER CHAR(1),
	SALARY BIGINT);   # the list of columns to be remained in the table

#set delimiter at alter
ALTER TABLE EMPLOYEE 
SET SERDEPROPERTIES('field.delim'=',');

#Delete data in the table
TRUNCATE TABLE EMPLOYEE;

#Drop the table
DROP TABLE EMPLOYEE;



**HDFS CLI INTERFACE**
-----------------------

Hadoop fs or hdfs dfs

#to list
hadoop fs -ls

#To create directory
hadoop fs -mkdir /user/mohan/test

#to view contents of a file
hadoop fs -cat /user/mohan/employee/employee.txt

#to copy files from local to hdfs
hadoop fs -copyFromLocal /user/hive/employee.txt /user/mohan/employee/

(OR)

hadoop fs -put /user/hive/employee.txt /user/mohan/employee/

# to copy files from hdfs to local
hadoop fs -copyToLocal /user/mohan/employee/employee.txt /user/hive/

(OR)

hadoop fs -get /user/mohan/employee/employee.txt /user/hive/

# to copy files within file system
hadoop fs -cp /user/mohan/employee /user/mohan/

#to remove a file
hadoop fs -rm /user/mohan/employee/employee.txt

#to remove a dir
hadoop fs -rmdir /user/mohan/employee


#Run hive queries from file or outside
hive -e "select * from employee";

hive -f hive.sql




**HIVE FUNCTIONS**
------------------

#Built it functions
SHOW FUNCTIONS; --lists number of available functions

#describe
DESRCIBE FUNCTION CONCAT;
DESCRIBE FUNCTION EXTENDED CONCAT;



1.Standard functions - outputs one row for each row
	example : SELECT CONCAT(EMP_NAME," ", GENDER) FROM EMPLOYEE;

2.Aggregate functions - Outputs one row for a set of rows
	example : SELECT EMP_NAME,SUM(SALARY) FROM EMPLOYEE GROUP BY EMP_NAME;

3.Table generating functions - generate multiple rows for single row
	example : SELECT EXPLODE(ARRAY(1,2,3));


#Case statements
SELECT CASE WHEN SALARY<100000 THEN 'AVERAGE'
WHEN SALARY>=100000 AND SALARY<200000 THEN 'GOOD'
WHEN SALARY>=200000 THEN 'HIGH'
END AS SALARY_TYPE FROM EMPLOYEE;

#SIZE and CAST
Note: Size function works only for Array and Maps

SELECT SIZE(ARRAY(1,2,3)); #outputs 3

SELECT SIZE(MAP(1,"MOHAN",2,"RAM")); #outputs 2 -- number of key value pairs

SELECT CAST("25" AS BIGINT);

SELECT CAST(SALARY AS STRING) FROM EMPLOYEE;

#EXPLODE

note : Used to expand the collection elements in a column. For each element, a row is generated.

SELECT EXPLODE(ARRAY(1,2,3)); --gives 3 rows(1,2,3);

SELECT EMP_NAME,EXPL,EXPL2 FROM EMPLOYEE LATERAL VIEW EXPLODE(ADDRESS) EXPLTABLE AS EXPL,EXPL2;

SELECT EMP_NAME,EXPL,EXPL2,COUNT(*) FROM EMPLOYEE LATERAL VIEW EXPLODE(ADDRESS) EXPLTABLE AS EXPL,EXPL2 GROUP BY EMP_NAME,EXPL,EXPL2;

--sample data
1	"MOHANRAM KRISHNAN"	"IT"	"DATA SCIENTIST"	"M"	100000	"CITY":"Chennai","ZIP":"600100"
1	"MOHANRAM KRISHNAN"	"IT"	"DATA SCIENTIST"	"M"	100000	"CITY":"Madurai","ZIP":"600100"

--output
"MOHANRAM KRISHNAN"     "CITY"  "Chennai"       1
"MOHANRAM KRISHNAN"     "CITY"  "Madurai"       1
"MOHANRAM KRISHNAN"     "ZIP"   "600100"        2


**SUB-QUERRIES**
------------------

#IN 
note : should be only one column in subquery;

SELECT SALES_DATA.PRODUCT_NAME,REVENUE FROM SALES_DATA WHERE PRODUCT_NAME IN (SELECT PRODUCT_NAME FROM COMPANY_INFO);

--output
Apple   1000.5
Samsung 2000.75

#EXISTS
note : must match atleast one record in the exists sub-query. 

SELECT HEADQUARTERS FROM COMPANY_INFO WHERE EXISTS (SELECT PRODUCT_NAME FROM SALES_DATA WHERE COMPANY_INFO.PRODUCT_NAME=SALES_DATA.PRODUCT_NAME); 

--output
USA
Korea

--to insert collection data using insert command
CREATE TABLE HELLO
(
	ID INT,
	Name Array<STRING>
	ADDRESS STRUCT<Street:STRING,City:STRING>
	
);

INSERT INTO HELLO 
SELECT 1,array("Mohan","Ram"),named_struct("Street","C3,visha thulasi apts","City","Chennai") from EMPLOYEE limit 1; -- employee is dummy table here. Any dummy table reference works. limit 1 is important.

SELECT NAME[1],ADDRESS.City FROM HELLO;


--VIEWS
Note : 
1.Views are stored in hive metastore and not executed while creating a view.
2.Views are just a shortcut name for holding a set of queries.
3.views can be viewed using 'show tables' command and 'describe extended' command.
4.Purpose : To restrict access to table(by providing access to subset of a table instead of all columns), to build logical condition from a table using where clause, to reduce complexity.

CREATE VIEW EMPLOYEE_CITY
AS
SELECT * FROM EMPLOYEE WHERE ADDRESS["CITY"]='Madurai';

DROP VIEW EMPLOYEE_CITY;

ALTER VIEW EMPLOYEE_CITY
AS
SELECT * FROM EMPLOYEE WHERE ADDRESS["CITY"]='Chennai';




**PARTITIONS**
--------------
1.To improve Query performance
2.TO logically organize the data.
3.When a column is partitioned, a sub-directory is created under table directory in HDFS for each unique value in that column.
4.There can be many partitions in a table.
5.Choose partitions column wisely - the columns which are mostly used in filter & group by statement.
6.Choosing 'orderid' column as partition column for example, creates a lot of sub-directories inside hadoop and is over head to the namenode.
7.partitions can be only created during creating tables.
8.When a partition is created on a column, the partitioned column does not exist in the data file because it is redundant since the data file is under the sub-directory of partitioned column.
9.On create table command, parition column should be part of list of other columns, and needs to be specified under "partitioned by".


--setting - dynamic partition
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

Note: To alter permanently change this setting in HIVE_SITE.XML


#Strict vs Nonstrict mode
Strict -- needs to have atleast one non-dynamic partition.
Non strict -- all can be non-dynamic partition.


#creating a parition -- the below statement creates REGION sub directory under ORDER_YEAR sub-directory which is created under SALES_REVENUE in hdfs.

CREATE TABLE SALES_REVENUE
(
	SALES DECIMAL(10,2),
	CURRENCY_VALUE VARCHAR(5)
)

PARTITIONED BY 
(
	ORDER_YEAR DATE,
	REGION VARCHAR(50)
);

--static partition
INSERT OVERWRITE TABLE SALES_REVENUE 
PARTITION(ORDER_YEAR='2018-01-01',REGION='North America')
VALUES (50000,'$');



#strict mode -- order_year column is non-dynamic here (value is hardcoded)
INSERT OVERWRITE TABLE SALES_REVENUE 
PARTITION(ORDER_YEAR='2018-01-01',REGION)
SELECT SALES,CURRENCY_VALUE,REGION FROM SALES_REVENUE_NON_PARTITION;

#non_strict mode
INSERT OVERWRITE TABLE SALES_REVENUE 
PARTITION(ORDER_YEAR,REGION)
SELECT SALES,CURRENCY_VALUE,ORDER_YEAR,REGION FROM SALES_REVENUE_NON_PARTITION; --partition columns should be specified last in the select statement


DESCRIBE PARTITION SALES_REVENUE;
SHOW PARTITIONS SALES_REVENUE;








**BUCKETING**
-------------

1.Similar to partition, but with bucketing, the data is splitted for a set of records. Number of buckets are not equal to number of unique values in the bucketing column.
2.partition is useful only when number of unique values are less. Otherwise, namenode overhead will be greater for millions of directories.
3.bucketing is used for columns where number of unique values are higher.
4.Using modulo function in the backend, the column data gets spliited and records are placed in corresponding buckets.
5.This improves performance, as instead of lookup all buckets, the search will lookup only in a single bucket.
6.Must be specified under "CLUSTERED BY (COLUMN_NAME) INTO N BUCKETS"
7.All the data related to a bucket goes to a single file.
8.A table can have both partition column and bucket column.
9.USeful in map-side join performance. By using "SORTED BY(COLUMN_NAME) INTO N BUCKETS", the data in the bucket file is sorted on the column.

Ex: Primary key columns are ideal for bucketing columns, where unique values are relatively high. 


#setting
SET hive.enforce.bucketing=true;


CREATE TABLE STUDENT_BUCKET
(
	id INT,
	name VARCHAR(100),
	AGE INT
)

CLUSTERED BY (ID) INTO 5 BUCKETS;

INSERT INTO STUDENT_BUCKET VALUES(1,"MOHANRAM",27),(2,"NAGARAJ",27),(3,"KARTHICK",29);


--directory structure
-rwxrwxrwx   3 root hdfs         14 2018-05-24 04:09 /apps/hive/warehouse/student_bucket/000001_0
-rwxrwxrwx   3 root hdfs         13 2018-05-24 04:09 /apps/hive/warehouse/student_bucket/000002_0
-rwxrwxrwx   3 root hdfs         14 2018-05-24 04:09 /apps/hive/warehouse/student_bucket/000003_0


--PARTITIONED BY, CLUSTERED BY, SORTED BY
CREATE TABLE STUDENT_BUCKET_SORTED
(
	id INT,
	name VARCHAR(100),
	AGE INT
)

PARTITIONED BY (DEPT VARCHAR(50))
CLUSTERED BY (ID) 
SORTED BY(AGE) INTO 3 BUCKETS;

INSERT INTO STUDENT_BUCKET_SORTED PARTITION(DEPT="E&I") VALUES (2,"NAGARAJ",27),(3,"KARTHICK",29),(4,"ARUN",28),(5,"MANOJ",28),(6,"PONNU",26);
INSERT INTO STUDENT_BUCKET_SORTED PARTITION(DEPT="MECH") VALUES (1,"MOHANRAM",27);

--output
hadoop fs -cat /apps/hive/warehouse/student_bucket_sorted/dept=E&I/000002_0/;
6PONNU26
3KARTHICK29


--SAMPLING
select * from STUDENT_BUCKET_SORTED tablesample(bucket 3 out of 3 on ID); --list the contents from bucket 3.
select * from STUDENT_BUCKET_SORTED tablesampme (5 PERCENT);
select * from STUDENT_BUCKET_SORTED tablesample(5 rows);






**WINDOWING**
-------------
1. To obtain a set of rows and perform Aggregate calculations.

select description,salary,sum(salary) over (order by code rows between unbounded preceding and current row) as running_total from sample_07;

(OR)

select description,salary,sum(salary) over (order by code) as running_total from sample_07; -- unbounded preceding till current row is the hive default. so we can omit that from explicit specification.

2.If we want to set the running_total to 0 for every new value in a certain column.

SELECT EMP_NAME,EMP_DEPT,SUM(SALARY) OVER (PARTITION BY EMP_DEPT ORDER BY EMP_ID) FROM EMPLOYEE; --running total is set to 0 for every new value in EMP_DEPT column

--sample data
1       MURALI  MECH    DATA SCIENTIST  M       500000  {"CITY":"Chennai","ZIP":"600100"}
2       MOHANRAM KRISHNAN       IT      DATA SCIENTIST  M       100000  {"CITY":"Chennai","ZIP":"600100"}
3       MANOJ   IT      DEVELOPER       M       200000  {"CITY":"Chennai","ZIP":"600100"}
4       PONNU   MECH    DEVELOPER       M       500000  {"CITY":"Chennai","ZIP":"600100"}

--output
MOHANRAM KRISHNAN       IT      100000
MANOJ   IT      300000
MURALI  MECH    500000
PONNU   MECH    1000000

3. If we want to calculate a row level percentage contribution to a overall sum.

select emp_name,emp_dept,(salary*100)/(sum(salary) over (partition by emp_dept)) from employee;

--output
MOHANRAM KRISHNAN       IT      33.333333333333336
MANOJ   IT      66.66666666666667
MURALI  MECH    50.0
PONNU   MECH    50.0

4. RANK(), ROW_NUMBER()

SELECT EMP_NAME,EMP_DEPT,SALARY,RANK() OVER (PARTITION BY EMP_DEPT ORDER BY SALARY DESC) FROM EMPLOYEE; --rank based on salary. order by column determines the "basis".

--output
MANOJ   IT      200000  1
MOHANRAM KRISHNAN       IT      100000  2
MURALI  MECH    500000  1
PONNU   MECH    500000  1

SELECT EMP_NAME,EMP_DEPT,SALARY,ROW_NUMBER() OVER (PARTITION BY EMP_DEPT ORDER BY SALARY DESC) FROM EMPLOYEE;

--output
MANOJ   IT      200000  1
MOHANRAM KRISHNAN       IT      100000  2
MURALI  MECH    500000  1
PONNU   MECH    500000  2


**JOIN OPTIMIZATIONS IN HIVE**
-------------------------------

1.When more than two tables are joined, if the join column is same across tables in join condition, only one map-reduce job is allocated. Depends on the number of columns we join.
2.When more than two tables are joined, the table thats joined last is kept on streaming record by record and stays at hdfs. Other tables records are pulled into memory. Its important to keep largest size table as last table in join to improve performance.
3.To force hive to stream a particular table we can use the /*+ STREAMTABLE(ALUMNI) =*/ function.

Ex: EMPLOYEE - 5MB
    DEPT - 100MB
    ALUMNI - 1GB

    --it is better to keep the largest table(alumni) in the last join condition

CREATE TEMPORARY TABLE EMPLOYEE
 (
   ID INT,
   NAME VARCHAR(100),
   DEPT_ID INT
 );


CREATE TEMPORARY TABLE DEPT
 (
  ID INT,
  NAME VARCHAR(100)
 );


CREATE TEMPORARY TABLE ALUMNI
 (
  EMP_NAME VARCHAR(100),
  YEAR DATE
 );

INSERT INTO EMPLOYEE VALUES(1,'MOHANRAM',1);
INSERT INTO DEPT VALUES(1,'MECHANICAL'); 
INSERT INTO ALUMNI VALUES('MOHANRAM','2011-01-01');


SELECT EMPLOYEE.NAME,DEPT.NAME,YEAR(ALUMNI.YEAR)
FROM
EMPLOYEE JOIN DEPT ON (EMPLOYEE.DEPT_ID=DEPT.ID)
JOIN ALUMNI ON (ALUMNI.EMP_NAME=EMPLOYEE.NAME); 

--STREAMTABLE FUNCTION. Here eventhough alumni table is not joined in last, this is forcefully streamed and not brought to memory, which improves performance.

SELECT /*+ STREAMTABLE(ALUMNI) */ EMPLOYEE.NAME,DEPT.NAME,YEAR(ALUMNI.YEAR)
FROM
EMPLOYEE JOIN ALUMNI ON (ALUMNI.EMP_NAME=EMPLOYEE.NAME)
JOIN DEPT ON (EMPLOYEE.DEPT_ID=DEPT.ID);


--Output
MOHANRAM        MECHANICAL      2011



--LEFT SEMI JOIN
1. To get  all records from left table where matching column in right table.
2.Generally used to replace "EXISTS" in sql. with exists clause, only one column can be specified. With left semi join, multiple conditions can be specified.
3. With left semi join, only matching records are scanned in table 2. But with exists clause, entire table is scanned. Improves performance.
Refer to Joins Explained.sql file.



























