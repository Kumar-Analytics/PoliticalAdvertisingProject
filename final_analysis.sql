--Project Tables
--1)
With MaxSpendUSD AS
(select e.total_creatives, max(e.spend_usd) as Max_Spend_USD
from advertiser_stats1 e
WHERE e.total_creatives 
            < (select avg(total_creatives)
                from advertiser_stats1 
                where regions = 'US'
                and spend_usd <> 0)
AND spend_usd <> 0
group by e.total_creatives
)
Select avg(Max_Spend_USD) as Average_of_MaxSpendUSD
from MaxSpendUSD; -- The average of max spend_USD of (less than average) total creatives is $746,801

--2)
With MinSpendUSD AS
(select e.total_creatives, max(e.spend_usd) as Min_Spend_USD
from advertiser_stats1 e
WHERE e.total_creatives 
            > (select avg(total_creatives)
                from advertiser_stats1 
                where regions = 'US'
                and spend_usd <> 0)
AND spend_usd <> 0
group by e.total_creatives
)
Select avg(Min_Spend_USD) as Average_of_MinSpendUSD 
from MinSpendUSD; -- The average of max spend_USD of (higher than average) total creatives is $2,382,368

--3)
Select avg(b.spend_usd) as Avg_PublicIdSpend 
from (
    select top 5000 spend_usd, advertiser_name
    from advertiser_stats1
        where public_ids_list <> 'ID N/A'
        or public_ids_list is not null
        and regions = 'US' 
    order by 1 desc
) as b; --avg is $233,303 for listed public id 

--4)
Select avg(b.spend_usd) as Avg_PublicIdSpend 
from (
    select top 5000 spend_usd, advertiser_name
    from advertiser_stats1
        where public_ids_list = 'ID N/A'
        or public_ids_list is null
        and regions = 'US'
    order by 1 desc  
) as b; 

--5)
Select top 10000 a.advertiser_id,
max(distinct a.impressions) as MaxImpressionRanges,
Sum(b.total_creatives) as CreativeTotal, 
SUM(b.spend_usd) as Total_SpendUSD, 
SUM(cast(b.total_creatives as float))/Sum(cast(b.spend_usd as float))*100 as CreativePercentage 
From creative_stats a
join advertiser_stats1 b
on a.advertiser_id = b.advertiser_id
    where b.regions = 'US'
    and b.spend_usd <> 0 
group by a.advertiser_id
order by 1;

--6)
Select top 10000 a.advertiser_id,
max(distinct a.impressions) as MaxImpressionRanges,
Sum(b.total_creatives) as CreativeTotal, 
SUM(b.Foreign_Spend) as Total_Spend, 
SUM(cast(b.total_creatives as float))/Sum(cast(b.Foreign_Spend as float))*100 as CreativePercentage 
From creative_stats a
join advertiser_stats1 b
on a.advertiser_id = b.advertiser_id
    where b.regions <> 'US'
    and b.Foreign_Spend <> 0 
group by a.advertiser_id
order by 1;

--7)
select top 10000 a.advertiser_id, 
b.advertiser_name, 
a.ad_type, a.impressions,
a.date_range_start, 
a.spend_range_max_usd,
Sum(a.spend_range_max_usd) OVER 
    (partition by a.advertiser_id order by a.advertiser_name rows 
        between unbounded preceding and current row) 
    as Spend_by_Ad,
b.regions, b.public_ids_list
from creative_stats a 
join advertiser_stats1 b 
on a.advertiser_id = b.advertiser_id
where b.regions = 'US'
order by a.advertiser_id, Spend_By_Ad;

--8)
select top 10000 a.advertiser_id, 
b.advertiser_name, 
a.ad_type, a.impressions, 
a.date_range_start,
b.regions, b.public_ids_list
from creative_stats a 
join advertiser_stats1 b 
on a.advertiser_id = b.advertiser_id
where b.regions <> 'US'
order by a.advertiser_id

--9)
With AdTypeImpressions as (
    select distinct(a.advertiser_id), b.advertiser_name, a.ad_type, a.impressions
from creative_stats a 
join advertiser_stats1 b 
on a.advertiser_id = b.advertiser_id
where b.regions = 'US' 
and b.public_ids_list <> 'ID N/A'
or b.public_ids_list is not null
) 
Select ad_type, count(ad_type) as AdTypeMost from AdTypeImpressions
group by ad_type 
order by AdTypeMost desc;

--10)
With AdTypeImpressions as (
    select distinct(a.advertiser_id), b.advertiser_name, a.ad_type, a.impressions
from creative_stats a 
join advertiser_stats1 b 
on a.advertiser_id = b.advertiser_id
where b.regions <> 'US' 
) 
Select ad_type, count(ad_type) as AdTypeMost from AdTypeImpressions
group by ad_type 
order by AdTypeMost desc;

--11)
select top 200 a.advertiser_name,
sum(a.spend_USD) as SumSpendUSD,
sum(num_of_days) as Days,
count(distinct c.ad_type) as CountAdType
from creative_stats c
join advertiser_stats1 a
on c.advertiser_id = a.advertiser_id
where a.regions = 'US'
group by a.advertiser_name
order by 1 asc;

select 
*
from creative_stats;

--12)
select top 200 a.advertiser_name, 
sum(a.Foreign_Spend) as SumForeignSpend,
sum(num_of_days) as Days,
count(ad_type) as TotalAds,
count(distinct c.ad_type) as CountAdType
from creative_stats c
join advertiser_stats1 a
on c.advertiser_id = a.advertiser_id
where a.regions <> 'US'
group by a.advertiser_name
order by 1 asc;

--13)
select ad_type, 
avg(num_of_days) as avg_days, 
avg(spend_range_max_usd) as avg_maxspendUSD, 
count(ad_type) as common_ad
from creative_stats
where regions = 'US' 
group by ad_type
order by common_ad desc;

--14)
select ad_type, 
avg(num_of_days) as avg_days, 
avg(spend_range_max_usd) as avg_maxspendUSD, 
count(ad_type) as common_ad
from creative_stats
where regions <> 'US' 
group by ad_type
order by common_ad desc;

--15)
With SpendRange as
(select DISTINCT(b.advertiser_id), b.USD_SpendRange
from
    (select a.advertiser_id, SUM(c.spend_range_max_usd-c.spend_range_min_usd) OVER (Partition by a.advertiser_id) as USD_SpendRange
    from advertiser_stats1 a 
    left join creative_stats c 
    on a.advertiser_id = c.advertiser_id
    where ad_type = 'Image') b)
Select 
avg(USD_SpendRange) as avgUSD_SpendRange, 
max(USD_SpendRange) as maxUSD_SpendRange, 
min(USD_SpendRange) as minUSD_SpendRange 
from SpendRange;

--16)
With SpendRange as
(select DISTINCT(b.advertiser_id), b.USD_SpendRange
from
    (select a.advertiser_id, SUM(c.spend_range_max_usd-c.spend_range_min_usd) OVER (Partition by a.advertiser_id) as USD_SpendRange
    from advertiser_stats1 a 
    left join creative_stats c 
    on a.advertiser_id = c.advertiser_id
    where ad_type = 'Text') b)
Select 
avg(USD_SpendRange) as avgUSD_SpendRange, 
max(USD_SpendRange) as maxUSD_SpendRange, 
min(USD_SpendRange) as minUSD_SpendRange 
from SpendRange;

--17)
With SpendRange as
(select DISTINCT(b.advertiser_id), b.USD_SpendRange
from
    (select a.advertiser_id, SUM(c.spend_range_max_usd-c.spend_range_min_usd) OVER (Partition by a.advertiser_id) as USD_SpendRange
    from advertiser_stats1 a 
    left join creative_stats c 
    on a.advertiser_id = c.advertiser_id
    where ad_type = 'Video') b)
Select 
avg(USD_SpendRange) as avgUSD_SpendRange, 
max(USD_SpendRange) as maxUSD_SpendRange, 
min(USD_SpendRange) as minUSD_SpendRange 
from SpendRange;