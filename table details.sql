CREATE TABLE SALES_DATA
(
Product_id int,
product_name VARCHAR(100),
revenue decimal(10,2));

insert into sales_data values (1,"Apple",1000.50),(2,"Samsung",2000.75);

CREATE TABLE COMPANY_INFO
(
product_name varchar(100),
headquarters varchar(100)
);

insert overwrite table COMPANY_INFO values("Apple","USA"),("Samsung","Korea"),("Microsoft","USA");


CREATE TABLE SALES_REVENUE_NON_PARTITION
(
	SALES DECIMAL(10,2),
	CURRENCY_VALUE VARCHAR(5),
	ORDER_YEAR DATE,
	REGION VARCHAR(50)
);

INSERT INTO SALES_REVENUE_NON_PARTITION VALUES(10000,'$','2018-01-01','Asia');

