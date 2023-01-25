--Analysis Project: Political Advertising on Google
-- This dataset contains information on how much money is spent by verified advertisers on political advertising across Google Ad Services. 
--  In addition, insights on demographic targeting used in political ad campaigns by these advertisers are also provided. 


-- This table contains the information for election ads that have appeared on Google Ads Services. Ad-level targeting data was added to this file in April 2020.
select * from creative_stats;


-- This table contains the information about advertisers who have run an election ad on Google Ads Services with at least one impression. The table's primary key is advertiser_id. 
select * from advertiser_stats;


--Certain California and New Zealand advertisers are required to submit additional data about themselves. The advertiser is responsible for the accuracy of this information, which Google has not confirmed. 
-- For California, this information is provided from our express notification process required for certain California advertisers, which is separate from our verification process. 
-- For New Zealand, this information is provided during our verification process.
select* from advertiser_declared_stats;


-- Step 1: Data Cleaning / Filtering

Select * from advertiser_stats 
--Where public_ids_list is null , outside of US seems to be NULL
where regions = 'US'
AND public_ids_list is null; -- based on output, mostly seem to be individuals' campaigns, and spend USD seems lower
--order by regions

Select * from advertiser_stats 
Where regions = 'US'
AND public_ids_list is not null; -- based on output, seem to be larger campaigns with higher spend (USD)

-- Questions to answer for 'advertiser_stats' table:
    -- Which types of campaigns have the higher spend in the US?
    -- Which have the higher spend outside of US? 
    -- Difference in spend between political parties?
    -- Relationship between 'total creatives', 'spend' and campaigns in US, as well as outside US? 

SELECT a.advertiser_id, a.advertiser_name, a.public_ids_list, b.advertiser_id, b.advertiser_name, b.public_ids_list 
FROM advertiser_stats a 
JOIN advertiser_stats b 
    ON a.advertiser_name= b.advertiser_name
    AND a.advertiser_id <> b.advertiser_id
Where a.regions = 'US'
AND a.public_ids_list is null; -- is not null
-- hypothesis for is null is mostly true; most not null's are individual campaigns

select advertiser_name from advertiser_stats 
ORDER BY advertiser_name;

Update a
SET public_ids_list = 'ID N/A'
FROM advertiser_stats a 
JOIN advertiser_stats b 
    ON a.advertiser_name= b.advertiser_name
    AND a.advertiser_id <> b.advertiser_id
Where a.regions = 'US'
AND a.public_ids_list is null;

Select * from advertiser_stats 
WHERE regions = 'US'
AND public_ids_list = 'ID N/A';

Select len(advertiser_name) from advertiser_stats1;

Select avg(len(advertiser_name)) from advertiser_stats; --29 
Select avg(len(advertiser_name)) from advertiser_stats where regions like '%us%'; --25
Select avg(len(advertiser_name)) from advertiser_stats where regions not like '%us%'; --36

select 
  case 
    when len(advertiser_name)>45
    then left(advertiser_name, 45) + '...' 
    else advertiser_name end 
from advertiser_stats1;

Update advertiser_stats1
Set advertiser_name = 
    case 
        when len(advertiser_name)>45
        then left(advertiser_name, 45) + '...' 
        else advertiser_name end;

Select * from advertiser_stats1;

select elections from advertiser_stats1 where elections is not null; --all null

ALTER TABLE advertiser_stats1
DROP COLUMN elections;

--Update advertiser_stats 
--SET public_ids_list = 'ID N/A'
--FROM advertiser_stats 
--WHERE regions = 'US'
--AND public_ids_list is null;

Select * from advertiser_stats;


Select advertiser_id, advertiser_name, public_ids_list FROM advertiser_stats 
WHERE advertiser_name LIKE '%Cathy Mcmorris%';

--Remove duplicates
WITH RowNumCTE AS (
Select *, 
    row_number() OVER ( 
        Partition by 
            advertiser_id,
            advertiser_name,
            public_ids_list
            ORDER BY advertiser_id) row_num
FROM advertiser_stats 
)
Select * from RowNumCTE 
WHERE row_num > 1 
ORDER BY advertiser_id; --no duplicates in advertiser_stats
--test the same for creative_stats and advertiser_declared_stats
--delete unwanted rows
Select SUBSTRING(advertiser_name, 1, CHARINDEX('   ',advertiser_name)) as Name 
from  advertiser_stats;

Select * from advertiser_stats where advertiser_name like '%?%';

Select advertiser_id, advertiser_name from advertiser_stats1;

--Update advertiser_stats1
--SET public_ids_list = 'ID N/A'
--FROM advertiser_stats1 
--WHERE public_ids_list is null;

select * from advertiser_stats1;
--advertiser_stats cleaned

select * from creative_stats;

select ad_campaigns_list from creative_stats where ad_campaigns_list is not null;
select spend_usd from creative_stats where spend_usd is not null;
select age_targeting from creative_stats where age_targeting is not null;
-- split age targeting columns
select age_targeting from creative_stats;

Update creative_stats
Set age_targeting = 'Unknown' where age_targeting is null;

Select age_targeting, Substring(age_targeting, 1, Charindex(',', age_targeting)-1) as age,
Substring(age_targeting, Charindex(',', age_targeting)+1, LEN(age_targeting)) as  age2
from creative_stats where age_targeting is not null;

Select Substring(age_targeting, 1, Charindex(',', age_targeting)+1) as age
--Substring(age_targeting, 1, Charindex(',', age_targeting)-1) as age,
from creative_stats where age_targeting is not null and age_targeting <> 'Unknown';

select age_targeting from creative_stats where age_targeting is not null and age_targeting <> 'Unknown';

--try using parsename to split column
Select distinct(age_targeting) from creative_stats;

select age_targeting,
Case 
    when age_targeting = '18-24' then 'Young'
    when age_targeting like '25-34%' OR  age_targeting like '35-44%' then 'Adult'
    when age_targeting like '45-54%' then 'Middle Aged'
    when age_targeting LIKE '55-64%' then 'Mature'
    when age_targeting = '=65' then 'Elderly'
    else 'General' end age_groups 
from creative_stats;

alter table creative_stats -- might need to come back and fix
add age_groups as (case 
            when age_targeting = '18-24' then 'Young'
            when age_targeting like '25-34%' OR  age_targeting like '35-44%' then 'Adult'
            when age_targeting like '45-54%' then 'Middle Aged'
            when age_targeting LIKE '55-64%' then 'Mature'
            when age_targeting = '=65' then 'Elderly'
            else 'General' end);
select * from creative_stats;

select age_groups from creative_stats where age_groups = 'Middle Aged'


Select
PARSENAME(Replace(age_targeting, ',','.'),5),
PARSENAME(Replace(age_targeting, ',','.'),4),
PARSENAME(Replace(age_targeting, ',','.'),3),
PARSENAME(Replace(age_targeting, ',','.'),2),
PARSENAME(Replace(age_targeting, ',','.'),1)
from creative_stats 
where age_targeting LIKE '%18%';

--split gender targeting (boolean)
select * from creative_stats;
select distinct(gender_targeting) from creative_stats;


select distinct(gender_targeting),
Case 
    when gender_targeting like '%Male, Female%' OR gender_targeting like '%Unknown%' then 'Unisex'
    when gender_targeting like 'Female%' then 'Female'
    when gender_targeting like 'Male%' then 'Male'
    else 'N/A' end gender_groups
from creative_stats;

Update creative_stats
Set gender_targeting = 
    case 
    when gender_targeting like '%Male, Female%' OR gender_targeting like '%Unknown%' then 'Unisex'
    when gender_targeting like 'Female%' then 'Female'
    when gender_targeting like 'Male%' then 'Male'
    else 'N/A' end;


ALTER TABLE creative_stats 
DROP COLUMN geo_targeting_excluded;

ALTER TABLE creative_stats 
DROP COLUMN ad_campaigns_list;

Alter table creative_stats 
DROP COLUMN spend_usd; 

Select regions 
FROM creative_stats 
WHERE regions NOT LIKE '%US%';

Select regions 
FROM creative_stats
WHERE regions LIKE '%US%';

Select regions,
CASE When regions NOT LIKE '%US%' THEN 'International'
    ELSE regions
    END
FROM creative_stats;

Update creative_stats 
Set regions = CASE When regions NOT LIKE '%US%' THEN 'International'
    ELSE regions
    END;

Select distinct(regions), count(regions)
From creative_stats 
GROUP BY regions 
Order by 2;

Select distinct(ad_type), count(ad_type) 
FROM creative_stats
GROUP BY ad_type 
ORDER BY 2;

Select * from creative_stats;


select * from creative_stats
where gender_targeting is not null
AND regions = 'US'
Order by ad_type;

select * from advertiser_declared_stats;

select * from creative_stats;

--Remove duplicates
WITH RowNumCTE1 AS (
Select *, 
    row_number() OVER ( 
        Partition by 
            advertiser_id,
            advertiser_declared_name,
            advertiser_declared_regulatory_id
            ORDER BY advertiser_id) row_num
FROM advertiser_declared_stats 
)
Select * from RowNumCTE1 
WHERE row_num > 1 
ORDER BY advertiser_id; 


--Remove duplicates
WITH RowNumCTE2 AS (
Select *, 
    row_number() OVER ( 
        Partition by 
            ad_id,
            ad_type,
            advertiser_id,
            advertiser_name
            ORDER BY ad_id) row_num
FROM creative_stats 
)
Select * from RowNumCTE2 
WHERE row_num > 1 
ORDER BY ad_id; 

select * from advertiser_stats1;

select advertiser_id, sum(spend_eur + spend_inr + spend_bgn + spend_hrk + spend_czk + spend_dkk + spend_huf + spend_pln + spend_ron + spend_sek + spend_gbp + spend_nzd + spend_brl) 
from advertiser_stats1 
where regions <> 'US'
group by advertiser_id

select * from advertiser_stats1
where Foreign_Spend <> 0;

alter table advertiser_stats1
drop column Foreign_Spend;

Alter table advertiser_stats1 
Add Foreign_Spend as ( 
    spend_eur*1.06 + 
spend_inr*.012 + spend_bgn*.54 +
spend_hrk*.044 + spend_dkk*0.14 + 
spend_huf * .0027 + 
spend_pln * .23 + 
spend_ron * .22 +
spend_sek * .095 +
spend_gbp * 1.21 +
spend_nzd * .63 +
spend_brl * .19);

(spend_eur*1.06 + 
spend_inr*.012 + spend_bgn*.54 +
spend_hrk*.044 + spend_dkk*0.14 + 
spend_huf * .0027 + 
spend_pln * .23 + 
spend_ron * .22 +
spend_sek * .095 +
spend_gbp * 1.21 +
spend_nzd * .63 +
spend_brl * .19)
--no duplicates, ready to explore