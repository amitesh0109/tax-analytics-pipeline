with source as (
    select * from {{ ref('taxpayer_account') }}
),

renamed as (
    select
        account_id,
        taxpayer_name,
        tax_type_cd,
        district,
        cast(registration_date as date)  as registration_date,
        status                           as account_status
    from source
    where account_id is not null
)

select * from renamed