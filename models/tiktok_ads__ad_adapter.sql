
with hourly as (
    
    select *
    from {{ var('ad_report_hourly') }}

), campaigns as (

    select *
    from {{ ref('int_tiktok_ads__most_recent_campaign') }}

), ad_groups as (

    select *
    from {{ ref('int_tiktok_ads__most_recent_ad_group') }}

), ads as (

    select *
    from {{ ref('int_tiktok_ads__most_recent_ad') }}

), joined as (

    select 
        cast(hourly.stat_time_hour as date) as date_day,
        ad_groups.advertiser_id,
        -- ad_account_id, -- figure out where to pull
        -- ad_account_name, -- figure out where to pull
        campaigns.campaign_id,
        campaigns.campaign_name,
        ad_groups.ad_group_id,
        -- ad_groups.ad_group_name,
        ads.ad_id,
        ads.ad_name,
        ads.base_url,
        ads.url_host,
        ads.url_path,
        ads.utm_source,
        ads.utm_medium,
        ads.utm_campaign,
        ads.utm_content,
        ads.utm_term,
        sum(hourly.spend) as spend,
        sum(hourly.clicks) as clicks,
        sum(hourly.impressions) as impressions,
        sum(hourly.reach) as reach,
        sum(hourly.conversion) as conversion,
        sum(hourly.likes) as likes,
        sum(hourly.comments) as comments,
        sum(hourly.shares) as shares,
        sum(hourly.profile_visits) as profile_visits,
        sum(hourly.follows) as follows,
        sum(hourly.video_watched_2_s) as video_watched_2_s, 
        sum(hourly.video_watched_6_s) as video_watched_6_s, 
        sum(hourly.video_views_p_25) as video_views_p_25, 
        sum(hourly.video_views_p_50) as video_views_p_50,
        sum(hourly.video_views_p_75) as video_views_p_75
    from hourly
    left join ads
        on hourly.ad_id = ads.ad_id
    left join ad_groups 
        on ads.ad_group_id = ad_groups.ad_group_id
    left join campaigns
        on ads.campaign_id = campaigns.campaign_id
    {{ dbt_utils.group_by(15) }}
    


)

select *
from joined