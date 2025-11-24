{{ config(
    materialized='table'
) }}

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="cast('2030-12-31' as date)"
    ) }}
),

transformed as (
    select
        date_day as date_value,
        year(date_day) as year,
        quarter(date_day) as quarter,
        month(date_day) as month,
        monthname(date_day) as month_name,
        day(date_day) as day_of_month,
        dayofweek(date_day) as day_of_week,
        dayname(date_day) as day_name,
        case when dayofweek(date_day) in (1, 7) then true else false end as is_weekend,
        false as is_holiday,
        case 
            when month(date_day) >= 4 then year(date_day)
            else year(date_day) - 1
        end as fiscal_year,
        case 
            when month(date_day) in (4, 5, 6) then 1
            when month(date_day) in (7, 8, 9) then 2
            when month(date_day) in (10, 11, 12) then 3
            else 4
        end as fiscal_quarter,
        weekofyear(date_day) as week_of_year,
        current_timestamp() as load_timestamp,
        current_timestamp() as update_timestamp,
        'SYSTEM_GENERATED' as source_system
    from date_spine
)

select * from transformed
