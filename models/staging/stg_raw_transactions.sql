with source as (
    select * from {{ source('dbt_finance', 'raw_transactions') }}
),

cleaned as (
    select
        ft_id,
        account_id,
        period_id,
        tax_type_cd,
        ft_type_cd,
        CAST(amount as NUMERIC)         as amount,
        currency_cd,
        CAST(ft_date as DATE)           as ft_date,
        status,
        source_system,
        CAST(extracted_at as DATE)      as extracted_at,

        case when ft_type_cd = 'PAY'
            then abs(CAST(amount as NUMERIC))
            else 0 end                  as payment_amount,
        case when ft_type_cd = 'BILL'
            then CAST(amount as NUMERIC)
            else 0 end                  as billed_amount,
        case when ft_type_cd = 'PEN'
            then CAST(amount as NUMERIC)
            else 0 end                  as penalty_amount

    from source
    where ft_id is not null
)

select * from cleaned