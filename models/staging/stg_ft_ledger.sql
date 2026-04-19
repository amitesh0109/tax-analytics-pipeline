with source as (
    select * from {{ ref('ft_ledger') }}
),

renamed as (
    select
        ft_id                                    as ft_id,
        account_id                               as account_id,
        period_id                                as period_id,
        tax_type_cd                              as tax_type_cd,
        ft_type_cd                               as ft_type_cd,
        cast(amount as NUMERIC)           as amount,
        currency_cd                              as currency_cd,
        cast(ft_date as date)                    as ft_date,
        status                                   as ft_status,

        -- derived columns
        case when ft_type_cd = 'PAY' then abs(amount) else 0 end  as payment_amount,
        case when ft_type_cd = 'BILL' then amount     else 0 end  as billed_amount,
        case when ft_type_cd = 'PEN'  then amount     else 0 end  as penalty_amount,
        case when ft_type_cd = 'ADJ'  then amount     else 0 end  as adjustment_amount

    from source
    where ft_id is not null
)

select * from renamed