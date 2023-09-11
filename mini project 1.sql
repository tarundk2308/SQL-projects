# pie in the sky
# ipl match bidding app
create database miniproject1;
use miniproject1;
# 1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.
select temp1.bidder_id,ifnull(concat(round(temp2.win/temp1.tot*100),'%'),'not yet won') as win_percentage
from
(select bidder_id,count(bid_status) as tot from ipl_bidding_details group by bidder_id)temp1
left join
(select bidder_id,bid_status,count(bid_status) as win from ipl_bidding_details where bid_status = 'won' group by bidder_id)temp2
on temp1.bidder_id = temp2.bidder_id
order by win_percentage desc;

select bidder_id,(select bidder_id,ifnull(count(bidder_id),0) from ipl_bidding_details where bid_status = 'won' group by bidder_id) / (select bidder_id,count(bidder_id) from ipl_bidding_details group by bidder_id)from ipl_bidding_details ;


# 2.	Display the number of matches conducted at each stadium with the stadium name and city.
select count(ims.stadium_id),ist.stadium_name,ist.city
from ipl_match_schedule as ims join ipl_stadium as ist
on ims.stadium_id = ist.stadium_id
group by ist.stadium_name,ist.city;

# 3.	In a given stadium, what is the percentage of wins by a team which has won the toss?
select temp1.stadium_name,temp1.toss_win,temp2.total_win,concat(round((temp1.toss_win/temp2.total_win)*100),'%') as toss_win_match_percentage from
(select stadium_name,count(ipm.toss_winner) as toss_win
from ipl_stadium iss join ipl_match_schedule ims
on iss.stadium_id = ims.stadium_id
join ipl_match ipm
on ims.match_id = ipm.match_id
where ipm.toss_winner = ipm.match_winner
group by stadium_name)temp1
join
(select stadium_name,count(ipm.match_winner) as total_win
from ipl_stadium iss join ipl_match_schedule ims
on iss.stadium_id = ims.stadium_id
join ipl_match ipm
on ims.match_id = ipm.match_id
group by stadium_name)temp2
on temp1.stadium_name = temp2.stadium_name;


select stadium_id 'Stadium ID', stadium_name 'Stadium Name',
(select count(toss_winner) from ipl_match m join ipl_match_schedule ms on m.match_id = ms.match_id where ms.stadium_id = s.stadium_id and (toss_winner = match_winner)) /
(select count(stadium_id) from ipl_match_schedule ms where ms.stadium_id = s.stadium_id) * 100 as 'Percentage of Wins by teams who won the toss (%)'
from ipl_stadium s;


# 4.	Show the total bids along with the bid team and team name.
select sum(ibp.no_of_bids),ibd.bid_team,it.team_name
from ipl_team it join ipl_bidding_details ibd
on it.team_id = ibd.bid_team
join ipl_bidder_points ibp
on ibd.bidder_id = ibp.bidder_id
group by ibd.bid_team,it.team_name;

# 5.	Show the team id who won the match as per the win details.
select distinct(team_id) from ipl_team_standings where matches_won is not null;

# 6.	Display total matches played, total matches won and total matches lost by the team along with its team name.
select team_id,sum(matches_played) as total_played,sum(matches_won) as total_won,sum(matches_lost) as total_lost 
from ipl_team_standings group by team_id;

# 7.	Display the bowlers for the Mumbai Indians team.
select ip.player_name,itp.player_role,itp.remarks
from ipl_player ip inner join ipl_team_players itp
on ip.player_id = itp.player_id
where itp.player_role = 'bowler' and itp.remarks like '%mi%';

/*8.	How many all-rounders are there in each team, Display the teams with more than 4 
all-rounders in descending order.*/
select count(player_role),player_role,remarks from ipl_team_players where player_role = 'all-rounder' group by player_role,remarks having count(player_role) > 4;

/*9.	 Write a query to get the total bidders points for each bidding status of those bidders who bid on CSK when it won the match in M. Chinnaswamy Stadium bidding year-wise.
 Note the total bidders’ points in descending order and the year is bidding year.
               Display columns: bidding status, bid date as year, total bidder’s points*/
select bidding_status,year,total_points from(select sum(ibp.total_points) as total_points,ibd.bid_status as bidding_status,year(ibd.bid_date) as year,it.team_name
from ipl_bidder_points ibp join ipl_bidding_details ibd
on ibp.bidder_id = ibd.bidder_id
join ipl_team it
on ibd.bid_team = team_id
where ibd.bid_status = 'won' and it.team_name = 'chennai super kings' 
group by ibd.bid_status,year(ibd.bid_date),it.team_name)temp;

/*10.	Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
Note 
1. use the performance_dtls column from ipl_player to get the total number of wickets
2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
3.	Do not use joins in any cases.
4.	Display the following columns teamn_name, player_name, and player_role.*/
select substring_index(performance_dtls,'Dot',) from ipl_player;



# 11.	show the percentage of toss wins of each bidder and display the results in descending order based on the percentage
(select temp1.bidder_id,((count1)/(select count(toss_winner) from ipl_match))*100 as percentage_toss_wins from
(select bidder_id,count(toss_winner) as count1
from ipl_bidding_details ibd join ipl_match im
on bid_team = team_id1
where im.toss_winner = 1
group by ibd.bidder_id)temp1
union all
select temp2.bidder_id,((count2)/(select count(toss_winner) from ipl_match))*100 as percentage_toss_wins from
(select bidder_id,count(toss_winner) as count2
from ipl_bidding_details ibd join ipl_match im
on bid_team = team_id2
where im.toss_winner = 2
group by ibd.bidder_id)temp2)
order by percentage_toss_wins desc;


/* 12.	find the IPL season which has min duration and max duration.
Output columns should be like the below:
 Tournment_ID, Tourment_name, Duration column, Duration*/
 
select tournmt_id,tournmt_name,from_date,to_date,concat(duration,' max') as duration from (select tournmt_id,tournmt_name,from_date,to_date,datediff(to_date,from_date) as duration from ipl_tournament)temp  
where duration = (select max(datediff(to_date,from_date)) from ipl_tournament)group by tournmt_id
union all
select tournmt_id,tournmt_name,from_date,to_date,concat(duration,' min') as duration from (select tournmt_id,tournmt_name,from_date,to_date,datediff(to_date,from_date) as duration from ipl_tournament)temp  
where duration = (select min(datediff(to_date,from_date)) from ipl_tournament)group by tournmt_id;

/* 13.	Write a query to display to calculate the total points month-wise for the 2017 bid year. sort the results based on total points in descending order and month-wise in ascending order.
Note: Display the following columns:
1.	Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
Only use joins for the above query queries.*/
select* from(select ibd.bidder_id,ibd.bidder_name,year(ibid.bid_date) as year,month(ibid.bid_date) as month,sum(ibp.total_points) as total_points
from ipl_bidder_details ibd join ipl_bidding_details ibid
on ibd.bidder_id = ibid.bidder_id
join ipl_bidder_points ibp
on ibid.bidder_id = ibp.bidder_id
where year(ibid.bid_date) = 2017
group by ibd.bidder_id,ibd.bidder_name,year(ibid.bid_date),month(ibid.bid_date) order by month(ibid.bid_date) asc)temp order by total_points desc;

# 14.	Write a query for the above question using sub queries by having the same constraints as the above question.
select bidder_id,bidder_name from ipl_bidder_details where bidder_id in (select bidder_id from ipl_bidding_details);


/* 15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
Output columns should be:
like:
Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder;*/
select ibp.bidder_id,tournmt_id,sum(total_points),bidder_name 
from ipl_bidder_points ibp join ipl_bidder_details ibd
on ibp.bidder_id = ibd.bidder_id
where tournmt_id = 2018 group by bidder_id,tournmt_id order by sum(total_points) ;

select* from(select ibp.bidder_id,dense_rank() over(order by total_points) as rank_bid,total_points,bidder_name
from ipl_bidder_points ibp join ipl_bidder_details ibd
on ibp.bidder_id = ibd.bidder_id)temp
where rank_bid in (1,2,3,14,15,16);


/*16.	Create two tables called Student_details and Student_details_backup.

Table 1: Attributes 		Table 2: Attributes
Student id, Student name, mail id, mobile no.	Student id, student name, mail id, mobile no.

Feel free to add more columns the above one is just an example schema.
Assume you are working in an Ed-tech company namely Great Learning where you will be inserting and modifying the details of the students 
in the Student details table. Every time the students changed their details like mobile number,
 You need to update their details in the student details table.  Here is one thing you should 
 ensure whenever the new students' details come , you should also store them in the Student 
 backup table so that if you modify the details in the student details table, you will be having the old details safely.
You need not insert the records separately into both tables rather Create a trigger in 
such a way that It should insert the details into the Student back table when you inserted the student details into the student table automatically.*/

create table student_details (
    student_id int primary key,
    student_name varchar(50),
    mail_id varchar(50),
    mobile_no varchar(15)
);

create table student_details_backup (
    student_id int primary key,
    student_name varchar(50),
    mail_id varchar(50),
    mobile_no varchar(15)
);

create trigger student_backup after insert on student_details for each row insert into student_details_backup 
values(new.student_id,new.student_name,new.mail_id,new.mobile_no);



