{{ config(
    materialized='table',
    cluster_by=['date_id', 'fiscal_year']
) }}

with date_spine as (
    select 
        dateadd(day, row_number() over (order by 1) - 1, '2020-01-01'::date) as date_value
    from table(generator(rowcount => 4018)) -- 11 years of dates (2020-2030)
),

date_transformations as (
    select
        row_number() over (order by date_value) as date_id,
        date_value,
        
        -- Calendar attributes
        year(date_value) as year,
        quarter(date_value) as quarter,
        month(date_value) as month,
        monthname(date_value) as month_name,
        day(date_value) as day_of_month,
        dayofweek(date_value) as day_of_week,
        dayname(date_value) as day_name,
        
        -- Weekend flag
        case when dayofweek(date_value) in (1, 7) then true else false end as is_weekend,
        
        -- Holiday flag (placeholder)
        false as is_holiday,
        
        -- Fiscal year calculations (April 1st start)
        case 
            when month(date_value) >= 4 then year(date_value)
            else year(date_value) - 1
        end as fiscal_year,
        
        case 
            when month(date_value) in (4, 5, 6) then 1
            when month(date_value) in (7, 8, 9) then 2
            when month(date_value) in (10, 11, 12) then 3
            else 4
        end as fiscal_quarter,
        
        weekofyear(date_value) as week_of_year,
        
        -- Metadata
        current_date as load_date,
        current_date as update_date,
        'SYSTEM_GENERATED' as source_system
        
    from date_spine
)

select * from date_transformations
