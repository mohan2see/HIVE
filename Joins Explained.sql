Joins Explained

table1

1,wqe,chennai,india

2,stu,salem,india

3,mia,bangalore,india

4,yepie,newyork,USA

table2

1,wqe,chennai,india

2,stu,salem,india

3,mia,bangalore,india

5,chapie,Los angels,USA

Inner Join

SELECT * FROM table1 INNER JOIN table2 ON (table1.id = table2.id);

1 wqe chennai india 1 wqe chennai india

2 stu salem india 2 stu salem india

3 mia bangalore india 3 mia bangalore india

Left Join

SELECT * FROM table1 LEFT JOIN table2 ON (table1.id = table2.id);

1 wqe chennai india 1 wqe chennai india

2 stu salem india 2 stu salem india

3 mia bangalore india 3 mia bangalore india

4 yepie newyork USA NULL NULL NULL NULL

Left Semi Join

SELECT * FROM table1 LEFT SEMI JOIN table2 ON (table1.id = table2.id);

1 wqe chennai india

2 stu salem india

3 mia bangalore india

note: Only records in left table are displayed whereas for Left Join both the table records displayed