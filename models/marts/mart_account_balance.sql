with ft as (
    select * from {{ ref('stg_ft_ledger') }}
),

accounts as (
    select * from {{ ref('stg_taxpayer_account') }}
),

balances as (
    select
        ft.account_id,
        a.taxpayer_name,
        a.tax_type_cd,
        a.district,
        a.account_status,

        sum(ft.billed_amount)                    as total_billed,
        sum(ft.payment_amount)                   as total_paid,
        sum(ft.penalty_amount)                   as total_penalties,
        sum(ft.billed_amount)
            - sum(ft.payment_amount)             as current_balance,

        count(distinct ft.period_id)             as periods_active,

        case
            when sum(ft.billed_amount)
                - sum(ft.payment_amount) > 50000  then 'HIGH'
            when sum(ft.billed_amount)
                - sum(ft.payment_amount) > 10000  then 'MEDIUM'
            when sum(ft.billed_amount)
                - sum(ft.payment_amount) > 0      then 'LOW'
            else 'CLEAR'
        end                                      as debt_risk_flag

    from ft
    left join accounts a on ft.account_id = a.account_id
    group by 1,2,3,4,5
)

select * from balances
order by current_balance desc