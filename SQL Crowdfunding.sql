 #---------- . Convert the Date fields to Natural Time ---------------#  
 
SELECT DATE_FORMAT(FROM_UNIXTIME(created_at), '%Y-%m-%d') AS natural_time
FROM crowdfunding.projects;

SELECT 
    FROM_UNIXTIME(created_at, '%Y-%m-%d') AS created_at_date,
    FROM_UNIXTIME(created_at, '%H:%i:%s') AS created_at_time,
    FROM_UNIXTIME(deadline, '%Y-%m-%d') AS deadline_date,
    FROM_UNIXTIME(deadline, '%H:%i:%s') AS deadline_time,
    FROM_UNIXTIME(updated_at, '%Y-%m-%d') AS updated_at_date,
    FROM_UNIXTIME(updated_at, '%H:%i:%s') AS updated_at_time,
    FROM_UNIXTIME(state_changed_at, '%Y-%m-%d') AS state_changed_at_date,
    FROM_UNIXTIME(state_changed_at, '%H:%i:%s') AS state_changed_at_time,
    FROM_UNIXTIME(successful_at, '%Y-%m-%d') AS successful_at_date,
    FROM_UNIXTIME(successful_at, '%H:%i:%s') AS successful_at_time,
    FROM_UNIXTIME(launched_at, '%Y-%m-%d') AS launched_at_date,
    FROM_UNIXTIME(launched_at, '%H:%i:%s') AS launched_at_time
FROM crowdfunding.projects
LIMIT 0, 50000;

SELECT goal * static_usd_rate AS goal_amount_usd
FROM crowdfunding.projects;

#--------------Total Number of Projects ------------------#

SELECT 
    COUNT(ProjectID) AS TotalProjects
FROM crowdfunding.projects;

#--------------Total Number of Projects based on Outcome----------------#

SELECT 
    state,
	COUNT(state) AS TotalProjects
FROM crowdfunding.projects
GROUP BY 
    state;

#--------------Total Number of Projects based on Locations--------------#

SELECT 
    country,
    COUNT(country) AS TotalProjects
FROM crowdfunding.projects
GROUP BY 
    country;
    
#--------------Total Number of Projects based on Category--------------#

SELECT 
    name,
    COUNT(name) AS 'Total Projects'
FROM crowdfunding.projects
GROUP BY  
        name;

#--------------Total Number of Projects created by Year, Quarter, Month-------------#

USE your_database_name;

WITH cte AS (
    SELECT 
        YEAR(FROM_UNIXTIME(created_at)) AS `year`,
        QUARTER(FROM_UNIXTIME(created_at)) AS `quarter`,
        MONTH(FROM_UNIXTIME(created_at)) AS `month`,
        COUNT(*) AS `count`,
        (SELECT COUNT(*) FROM crowdfunding.projects) AS `total_count`
    FROM crowdfunding.projects
    GROUP BY 
        YEAR(FROM_UNIXTIME(created_at)),
        QUARTER(FROM_UNIXTIME(created_at)),
        MONTH(FROM_UNIXTIME(created_at))
    ORDER BY 
        YEAR(FROM_UNIXTIME(created_at)) ASC,
        QUARTER(FROM_UNIXTIME(created_at)) ASC,
        MONTH(FROM_UNIXTIME(created_at)) ASC
)
SELECT 
    *,
    (count / total_count) * 100 AS `%_of_total` 
FROM 
    cte;

#----------------------Successful Projects-----------------------#

SELECT 
    COUNT(*) AS 'Successful Project'
FROM crowdfunding.projects
WHERE 
    state = 'successful';
    
#-------------------------Amount Raised------------------------#

SELECT
	SUM(usd_pledged) AS 'Amount raised'
FROM crowdfunding.projects
WHERE 
    state ='successful';
    
#-------------------------Number of Backers---------------------#

SELECT 
    SUM(backers_count) AS 'Number of Backers'
FROM crowdfunding.projects
WHERE 
     state = 'successful';
     
#------------------Avg NUmber of Days for successful projects------------------#

SELECT 
    AVG(DATEDIFF(FROM_UNIXTIME(successful_at), FROM_UNIXTIME(created_at))) AS 'Avg Number of Day'
FROM crowdfunding.projects
WHERE 
    state = 'successful';

#--------------------- Top Successful Projects Based on Number of Backers----------------------#

SELECT 
    ProjectID,
    name,
    backers_count
FROM crowdfunding.projects
WHERE 
    state = 'successful'
ORDER BY 
    backers_count DESC
LIMIT 10; -- Limiting to top 10 successful projects

#------------------Top Successful Projects Based on Amount Raised-------------#

SELECT 
    ProjectID,
	name,
    pledged
FROM crowdfunding.projects
WHERE 
    state = 'successful'
ORDER BY 
    pledged
LIMIT 10; -- Limiting to top 10 successful projects

#-------------------Percentage of Successful Projects overall------------------#

SELECT 
    COUNT(CASE WHEN state = 'successful' THEN 1 END) / COUNT(*) * 100 AS 'Overall Percentage'
FROM crowdfunding.projects;

#-------------------Percentage of Successful Projects  by Category------------------#

select 
    c.category_name,
    SUM(case when fp.state = 'successful' then	 1 else 0 end) as successful_projects,
    concat(LEAST((SUM( fp.state = 'successful') / COUNT(fp.ProjectID)) * 100, 100),"%") as success_percentage
from 
    category c
left join 
    projects fp on c.cate_id = fp.category_id
group by 
    c.cate_id, c.category_name;

#-----------------Percentage of Successful Projects by Year, Month, Quarter--------------#

SELECT 
    YEAR(FROM_UNIXTIME(created_at)) AS year,
    QUARTER(FROM_UNIXTIME(created_at)) AS quarter,
    MONTH(FROM_UNIXTIME(created_at)) AS month,
    (COUNT(CASE WHEN state = 'successful' THEN 1 END) / COUNT(*)) * 100 AS 'percentage_successful_by_year_month_quarter'
FROM crowdfunding.projects
GROUP BY 
    YEAR(FROM_UNIXTIME(created_at)),
    QUARTER(FROM_UNIXTIME(created_at)),
    MONTH(FROM_UNIXTIME(created_at));

#-------------------Percentage of Successful Projects by Goal Range---------------------#

SELECT 
    CASE 
        WHEN goal < 1000 THEN 'Less than 1000'
        WHEN goal >= 1000 AND goal < 5000 THEN '1000 - 4999'
        WHEN goal >= 5000 AND goal < 10000 THEN '5000 - 9999'
        ELSE '10000 and above'
    END AS goal_range,
    (COUNT(CASE WHEN state = 'successful' THEN 1 END) / COUNT(*)) * 100 AS percentage_successful_by_goal_range
FROM crowdfunding.projects
GROUP BY 
    CASE 
        WHEN goal < 1000 THEN 'Less than 1000'
        WHEN goal >= 1000 AND goal < 5000 THEN '1000 - 4999'
        WHEN goal >= 5000 AND goal < 10000 THEN '5000 - 9999'
        ELSE '10000 and above'
    END;

#------------------------------Completed----------------------------------------------#
