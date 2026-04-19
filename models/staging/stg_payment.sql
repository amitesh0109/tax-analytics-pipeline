with source as (
    select * from {{ ref('payment') }}
),

renamed as (
    select
        payment_id,
        account_id,
        ft_id,
        cast(payment_date as date)       as payment_date,
        cast(amount as NUMERIC)    as amount,
        currency_cd,
        payment_method,
        reference_no,
        status                           as payment_status
    from source
    where payment_id is not null
)

select * from renamed