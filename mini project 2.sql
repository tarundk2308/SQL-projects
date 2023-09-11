# about sales and delivery
use miniproject2;
# Question 1: Find the top 3 customers who have the maximum number of orders
select* from (select cust_id,order_quantity,dense_rank()over(order by order_quantity desc) as rank1 from market_fact)temp where rank1 in (1,2,3);
select Cust_id,sum(Order_Quantity) from market_fact group by Cust_id order by sum(Order_Quantity) desc limit 3;

# Question 2: Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.
select od.order_id,od.order_date,sd.ship_date,datediff(str_to_date(sd.ship_date,'%d-%m-%y'),str_to_date(od.order_date,'%d-%m-%y')) as daystakenfordelivery
from orders_dimen od join shipping_dimen sd
on od.order_id = sd.order_id;

# Question 3: Find the customer whose order took the maximum time to get delivered.
select* from cust_dimen where cust_id = (select distinct(mf.cust_id) from market_fact mf where ord_id = 
(select id from (select od.ord_id as id,od.order_date,sd.ship_date,datediff(str_to_date(sd.ship_date,'%d-%m-%y'),str_to_date(od.order_date,'%d-%m-%y')) as daystakenfordelivery
from orders_dimen od join shipping_dimen sd
on od.order_id = sd.order_id)temp order by daystakenfordelivery desc limit 1));

# Question 4: Retrieve total sales made by each product from the data (use Windows function)
select distinct(prod_id),sum(sales) over(partition by prod_id order by prod_id) as totalsales from market_fact;

# Question 5: Retrieve the total profit made from each product from the data (use windows function)
select distinct(prod_id),sum(profit) over(partition by prod_id order by prod_id) as totalsales from market_fact ;

# Question 6: Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
select count(distinct(mf.cust_id))
from orders_dimen od join market_fact mf
on od.ord_id = mf.ord_id
where month(str_to_date(od.order_date,'%d-%m-%y')) = 1 and  year(str_to_date(od.order_date,'%d-%m-%y')) = 2011;

# about restaurant

# Question 1: - We need to find out the total visits to all restaurants under all alcohol categories available.
select count(userid) as total_visits from rating_final where placeid in (select placeid from geoplaces2 where alcohol <> 'no_alcohol_served');

# Question 2: -Let's find out the average rating according to alcohol and price so that we can understand the rating in respective price categories as well.
select avg(rf.rating) avg_rating,gp.price,gp.alcohol
from rating_final rf join geoplaces2 gp
on rf.placeid = gp.placeid
group by gp.price,gp.alcohol;

# Question 3:  Let’s write a query to quantify that what are the parking availability as well in different alcohol categories along with the total number of restaurants.
select gp.alcohol,cp.parking_lot,count(gp.placeid)
from geoplaces2 gp join chefmozparking cp
on gp.placeid = cp.placeid
group by gp.alcohol,cp.parking_lot;

# Question 4: -Also take out the percentage of different cuisine in each alcohol type.
select c.rcuisine,g.alcohol,concat(round(count(c.placeid)/
(select count(placeid) 
from chefmozcuisine 
where rcuisine = c.rcuisine
group by rcuisine)*100),' %') as percentage
from chefmozcuisine c join geoplaces2 g
on c.placeid = g.placeid
group by c.rcuisine,g.alcohol;

# Let us now look at a different prospect of the data to check state-wise rating.

# Questions 5: - let’s take out the average rating of each state.
select avg(r.rating),g.state
from rating_final r join geoplaces2 g
on r.placeid = g.placeid
group by g.state
order by avg(r.rating);



/*Questions 6: -' Tamaulipas' Is the lowest average rated state. 
Quantify the reason why it is the lowest rated by providing the summary on the basis of State, alcohol, and Cuisine.*/
select g.placeid,g.state,g.alcohol,c.rcuisine
from geoplaces2 g left join chefmozcuisine c
on g.placeid = c.placeid
where g.state = 'tamaulipas';

select g.placeid, g.state, g.alcohol,(select rcuisine from chefmozcuisine where placeid = g.placeid)
FROM geoplaces2 g
WHERE g.state = 'tamaulipas';

/*Question 7:  - Find the average weight, food rating, and service rating of the customers who have visited KFC and tried Mexican or Italian types of cuisine,
 and also their budget level is low. We encourage you to give it a try by not using joins.*/
select avg(up.weight),avg(rf.food_rating),avg(rf.service_rating)
from rating_final rf join geoplaces2 g
on rf.placeid = g.placeid
join usercuisine u
on rf.userid = u.userid
join userprofile up
on u.userid=up.userid 
where g.name = 'kfc'
and u.rcuisine in ('mexican','italian') and g.price = 'low';

select (select avg(weight) from userprofile where userid in (select userid from usercuisine where rcuisine in ('mexican','Italian'))),avg(rf.food_rating),avg(rf.service_rating) from rating_final rf where 
rf.userid in (select userid from usercuisine where rcuisine in ('mexican','Italian'))
and rf.placeid in (select placeid from geoplaces2 where name ='kfc');

/*Part 3:  Triggers
Question 1:
Create two called Student_details and Student_details_backup.

Table 1: Attributes 		Table 2: Attributes
Student id, Student name, mail id, mobile no.	Student id, student name, mail id, mobile no.

You have the above two tables Students Details and Student Details Backup. Insert some records into Student details. 
Problem:
Let’s say you are studying SQL for two weeks. In your institute, there is an employee who has been maintaining the student’s details and Student Details Backup tables. He / She is deleting the records from the Student details after the students completed the course and keeping the backup in the student details backup table by inserting the records every time. You are noticing this daily and now you want to help him/her by not inserting the records for backup purpose when he/she delete the records.write a trigger that should be capable enough to insert the student details in the backup table whenever the employee deletes records from the student details table.
Note: Your query should insert the rows in the backup table before deleting the records from student details.*/

create table student_details(
student_id int primary key,
student_name varchar(30),
mail_id varchar(30),
mobile_no varchar(10));


create table student_details_backup(
student_id int primary key,
student_name varchar(30),
mail_id varchar(30),
mobile_no varchar(10));


create trigger student_details_trigger after delete on student_details
for each row insert into student_details_backup values (old.student_id,old.student_name,old.mail_id,old.mobile_no);

insert into student_details values(1,'123','123@gmail.com',9999999999);
select* from student_details;
select* from student_details_backup;
delete from student_details where student_id = 1;