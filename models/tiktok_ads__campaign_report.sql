with hourly as (
    
    select *
    from {{ var('campaign_report_hourly') }}
), 

campaigns as (

    select *
    from {{ ref('int_tiktok_ads__most_recent_campaign') }}
), 

advertiser as (

    select *
    from {{ var('advertiser') }}
), 

aggregated as (

    select
        cast(hourly.stat_time_hour as date) as date_day,
        advertiser.advertiser_id,
        advertiser.advertiser_name,
        hourly.campaign_id,
        campaigns.campaign_name,
        advertiser.currency,
        sum(hourly.impressions) as impressions,
        sum(hourly.clicks) as clicks,
        sum(hourly.spend) as spend,
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
        sum(hourly.video_views_p_75) as video_views_p_75,
        sum(hourly.spend)/nullif(sum(hourly.clicks),0) as daily_cpc,
        (sum(hourly.spend)/nullif(sum(hourly.impressions),0))*1000 as daily_cpm,
        (sum(hourly.clicks)/nullif(sum(hourly.impressions),0))*100 as daily_ctr
        
        {% for metric in var('tiktok_ads__campaign_hourly_passthrough_metrics', []) %}
        , sum(hourly.{{ metric }}) as {{ metric }}
        {% endfor %}
    from hourly
    left join campaigns
        on hourly.campaign_id = campaigns.campaign_id
    left join advertiser
        on campaigns.advertiser_id = advertiser.advertiser_id
    {{ dbt_utils.group_by(6) }}

)

select *
from aggregated