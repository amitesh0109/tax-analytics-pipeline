with ft as (
    select * from {{ ref('stg_ft_ledger') }}
    where tax_type_cd = 'PAYE'
),

periods as (
    select * from {{ ref('stg_tax_period') }}
),

accounts as (
    select * from {{ ref('stg_taxpayer_account') }}
    where tax_type_cd = 'PAYE'
),

paye_summary as (
    select
        ft.account_id,
        a.taxpayer_name,
        a.district,
        ft.period_id,
        p.period_year,
        p.period_month,
        p.due_date,

        sum(ft.billed_amount)                       as expected_paye,
        sum(ft.payment_amount)                      as actual_paye,
        sum(ft.penalty_amount)                      as penalties_raised,

        sum(ft.billed_amount)
            - sum(ft.payment_amount)                as variance,

        round(
            sum(ft.payment_amount)
            / nullif(sum(ft.billed_amount), 0)
            * 100, 2)                               as compliance_rate_pct,

        case
            when sum(ft.payment_amount)
                >= sum(ft.billed_amount)            then 'COMPLIANT'
            when sum(ft.payment_amount)
                >= sum(ft.billed_amount) * 0.8      then 'PARTIAL'
            else                                        'NON_COMPLIANT'
        end                                         as compliance_status,

        case
            when max(ft.ft_date) > p.due_date       then 'LATE'
            else                                        'ON_TIME'
        end                                         as payment_timing

    from ft
    left join periods p  on ft.period_id   = p.period_id
    left join accounts a on ft.account_id  = a.account_id
    group by 1,2,3,4,5,6,7
)

select * from paye_summary
order by period_year, period_month, compliance_status