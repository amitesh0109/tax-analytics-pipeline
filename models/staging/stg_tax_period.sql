with source as (
    select * from {{ ref('tax_period') }}
),

renamed as (
    select
        period_id,
        period_year,
        period_month,
        cast(start_date as date)  as start_date,
        cast(end_date as date)    as end_date,
        cast(due_date as date)    as due_date,
        period_status
    from source
    where period_id is not null
)

select * from renamed