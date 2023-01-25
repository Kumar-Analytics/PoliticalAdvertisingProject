-- Project 1 Analysis
-- Exploratory Analysis of Political Advertising Data

--find avg creatives for us campaigns, find avg spend for lower amt of creatives vs higher amt of creatives
select avg(total_creatives)
from advertiser_stats1 
where regions = 'US'
and spend_usd <> 0; --avg total creatives = 87


select e.total_creatives, max(e.spend_usd) as Max_Spend_USD
from advertiser_stats1 e
WHERE e.total_creatives 
            < (select avg(total_creatives)
                from advertiser_stats1 
                where regions = 'US'
                and spend_usd <> 0)
AND spend_usd <> 0
group by e.total_creatives
order by 1,2; --shows max spend by each # of creatives

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

--look at avg, min and max spend where public id is n/a vs not n/a

select * from advertiser_stats1;

select count(*) from advertiser_stats1 
    where public_ids_list <> 'ID N/A'
    and regions = 'US';  --count 7,970    

select count(*) from advertiser_stats1 
    where public_ids_list = 'ID N/A'
    or public_ids_list is null
    and regions = 'US';  --count 4,752

select * from advertiser_stats1
where Foreign_Spend <> 0;-- about 4000 rows

select public_ids_list, Foreign_Spend 
from advertiser_stats1
where public_ids_list is not null 
    and public_ids_list <> 'ID N/A'
    and regions <> 'US';

select avg(Foreign_Spend) as Avg_ForeignSpend 
from advertiser_stats1 
where regions <> 'US' --avg foreign spend is $532,527

Select avg(spend_usd)
from advertiser_stats1
    where public_ids_list <> 'ID N/A'
    and regions = 'US';

Select avg(b.spend_usd) as Avg_PublicIdSpend 
from (
    select top 5000 spend_usd, advertiser_name
    from advertiser_stats1
        where public_ids_list <> 'ID N/A'
        or public_ids_list is not null
        and regions = 'US' 
    order by 1 desc
) as b; --avg is $233,303 for listed public id 

Select avg(b.spend_usd) as Avg_PublicIdSpend 
from (
    select top 5000 spend_usd, advertiser_name
    from advertiser_stats1
        where public_ids_list = 'ID N/A'
        or public_ids_list is null
        and regions = 'US'
    order by 1 desc  
) as b; --avg is $1,706 for no public id

select top 500 spend_usd, advertiser_name from advertiser_stats1 
    where public_ids_list <> 'ID N/A'
    and regions = 'US'
    order by 1 desc; --top 500 seem to be political / climate committees (major names)

select top 500 spend_usd, advertiser_name from advertiser_stats1 
    where public_ids_list <> 'ID N/A'
    and regions = 'US'
    order by 1 asc; --bottom 500 seem to be minor political campaigns or healthcare related

select top 500 spend_usd, advertiser_name from advertiser_stats1 
    where public_ids_list = 'ID N/A'
    and regions = 'US'
    order by 1 desc; --top 100 seem to be mostly smaller, individual campaigns 

select top 500 spend_usd, advertiser_name from advertiser_stats1 
    where public_ids_list = 'ID N/A'
    and regions = 'US'
    order by 1 asc; --bottom 100 seem to be mostly smaller, individual campaigns 

Select advertiser_name, 
Sum(total_creatives) as CreativeTotal, 
SUM(spend_usd) as Total_SpendUSD, 
SUM(cast(total_creatives as float))/Sum(cast(spend_usd as float))*100 as CreativePercentage 
From advertiser_stats1 
    where regions = 'US'
    and spend_usd <> 0 
group by advertiser_name
order by 1;

Select top 200 advertiser_name, 
Sum(total_creatives) as CreativeTotal, 
SUM(spend_usd) as Total_SpendUSD, 
SUM(cast(total_creatives as float))/Sum(cast(spend_usd as float))*100 as CreativePercentage 
From advertiser_stats1 
    where regions = 'US'
    and spend_usd <> 0 
group by advertiser_name
order by 1 desc;


Select advertiser_name, 
Sum(total_creatives) as CreativeTotal, 
SUM(Foreign_Spend) as Total_Spend, 
SUM(cast(total_creatives as float))/Sum(cast(Foreign_Spend as float))*100 as CreativePercentage 
From advertiser_stats1 
    where regions <> 'US'
    and Foreign_Spend <> 0 
group by advertiser_name
order by 1;

Select top 200 advertiser_name, 
Sum(total_creatives) as CreativeTotal, 
SUM(Foreign_Spend) as Total_Spend, 
SUM(cast(total_creatives as float))/Sum(cast(Foreign_Spend as float))*100 as CreativePercentage 
From advertiser_stats1 
    where regions <> 'US'
    and Foreign_Spend <> 0 
group by advertiser_name
order by 1 desc;

select * from creative_stats;

select b.advertiser_id, distinct(b.impressions) 
from (select advertiser_id, impressions
from creative_stats) b
group by b.advertiser_id;

select * from advertiser_stats1
where regions = 'US';

select top 5000 a.advertiser_id, b.advertiser_name, a.ad_type, 
a.impressions, a.spend_range_max_usd,
Sum(a.spend_range_max_usd) OVER (partition by a.advertiser_id order by a.advertiser_name rows between unbounded preceding and current row) as Spend_by_Ad,
b.regions, b.public_ids_list
from creative_stats a 
join advertiser_stats1 b 
on a.advertiser_id = b.advertiser_id
where b.regions = 'US'
order by a.advertiser_id, Spend_By_Ad;

select top 5000 a.advertiser_id, b.advertiser_name, a.ad_type, 
a.impressions, a.spend_range_max_usd,
Sum(a.spend_range_max_usd) OVER (partition by a.advertiser_id order by a.advertiser_name rows between unbounded preceding and current row) as Spend_by_Ad,
b.regions, b.public_ids_list
from creative_stats a 
join advertiser_stats1 b 
on a.advertiser_id = b.advertiser_id
where b.regions <> 'US'
order by a.advertiser_id, Spend_By_Ad;


select * from creative_stats;

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




-- join with creative stats, look at total creatives / spend range per advertiser id
    -- do by each type of ad (image, video, text)
    -- might need to break these down by public id / no public id

-- total creatives / type of ad?
select * from creative_stats;

select a.advertiser_id, a.advertiser_name, 
c.ad_type, a.total_creatives
from advertiser_stats1 a
join creative_stats c
on a.advertiser_id = c.advertiser_id
where ad_type = 'IMAGE';

select a.advertiser_id, a.advertiser_name, 
c.ad_type, a.total_creatives
from advertiser_stats1 a
join creative_stats c
on a.advertiser_id = c.advertiser_id
where ad_type = 'TEXT';

select a.advertiser_id, a.advertiser_name, 
c.ad_type, a.total_creatives
from advertiser_stats1 a
join creative_stats c
on a.advertiser_id = c.advertiser_id
where ad_type = 'VIDEO';

select top 1000 a.advertiser_name, 
sum(a.spend_USD) as SumSpendUSD, 
count(ad_type) as CountAdType
from creative_stats c
join advertiser_stats1 a
on c.advertiser_id = a.advertiser_id
where a.regions = 'US'
group by a.advertiser_name
order by 1 desc;

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

select top 200 b.advertiser_id, count(distinct b.ad_type) as Count_Ads from
(select advertiser_id, advertiser_name, ad_type,
Count(ad_type) OVER (Partition by advertiser_id) as CountAdType
from creative_stats
) b
group by b.advertiser_id
order by b.advertiser_id desc;

select ad_type, COUNT(ad_type) as common_ad 
from creative_stats 
group by ad_type
order by common_ad desc;

select ad_type, 
avg(num_of_days) as avg_days, 
avg(spend_range_max_usd) as avg_maxspendUSD, 
count(ad_type) as common_ad
from creative_stats
where regions = 'US' 
group by ad_type
order by common_ad desc;

select * from creative_stats;

select spend_inr, spend_bgn, spend_hrk, spend_dkk, spend_huf, spend_sek from advertiser_stats1;

select spend_inr*.012, spend_bgn*.54, 
spend_hrk*.044, spend_dkk*0.14, 
spend_huf * .0027, 
spend_pln * .23,
spend_ron * .22,
spend_sek * .095,
spend_gbp * 1.21,
spend_nzd * .63,
spend_brl * .19
from advertiser_stats1; 

select spend_eur*1.06 from advertiser_stats1;

select Foreign_Spend from advertiser_stats1;

-- find which type of ad mostly used for top 1000 / bottom 1000 advertisers (big campaigns vs small campaigns)
    -- break this down by years/periods

select a.advertiser_id, c.spend_range_min_usd, c.spend_range_max_usd
from advertiser_stats1 a 
left join creative_stats c 
on a.advertiser_id = c.advertiser_id;

With SpendRange as
(select DISTINCT(b.advertiser_id), b.USD_SpendRange
from
    (select a.advertiser_id, SUM(c.spend_range_max_usd-c.spend_range_min_usd) OVER (Partition by a.advertiser_id) as USD_SpendRange
    from advertiser_stats1 a 
    left join creative_stats c 
    on a.advertiser_id = c.advertiser_id) b)
Select avg(USD_SpendRange) as avgUSD_SpendRange from SpendRange; -- Average spend range per adv_id is $3,448 in US.

select distinct(ad_type) from creative_stats; -- Image, Text, Video

With SumSpend as (
Select Distinct(b.advertiser_id), b.MaxSpend from
(select advertiser_id, SUM(spend_range_max_usd) OVER (Partition by advertiser_id) as MaxSpend 
from creative_stats where ad_type = 'Image') b)
Select Max(MaxSpend) from SumSpend;

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
from SpendRange;--Avg spend range per adv_id is $2,411 for TEXT ad types.
--Select max(USD_SpendRange) as avgUSD_SpendRange from SpendRange; max is $1,236,400 for Text
-- min is $100  

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
from SpendRange; --Avg spend range per adv_id is $3,134 for Video ad types.
-- max is $863,200 for Video
-- min is $100