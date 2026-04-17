with ft as (
    select * from {{ ref('stg_ft_ledger') }}
    where tax_type_cd = 'VAT'
),

periods as (
    select * from {{ ref('stg_tax_period') }}
),

accounts as (
    select * from {{ ref('stg_taxpayer_account') }}
    where tax_type_cd = 'VAT'
),

vat_summary as (
    select
        ft.account_id,
        a.taxpayer_name,
        a.district,
        ft.period_id,
        p.period_year,
        p.period_month,
        p.due_date,

        sum(ft.billed_amount)                       as output_vat,
        sum(ft.payment_amount)                      as vat_collected,
        sum(ft.penalty_amount)                      as penalties_raised,
        sum(ft.adjustment_amount)                   as adjustments,

        sum(ft.billed_amount)
            - sum(ft.payment_amount)                as net_vat_payable,

        round(
            sum(ft.payment_amount)
            / nullif(sum(ft.billed_amount), 0)
            * 100, 2)                               as collection_rate_pct,

        case
            when sum(ft.payment_amount)
                > sum(ft.billed_amount)             then 'REFUND_CANDIDATE'
            when sum(ft.payment_amount)
                >= sum(ft.billed_amount)            then 'SETTLED'
            when sum(ft.payment_amount)
                >= sum(ft.billed_amount) * 0.8      then 'PARTIAL'
            else                                        'OUTSTANDING'
        end                                         as vat_status

    from ft
    left join periods p  on ft.period_id  = p.period_id
    left join accounts a on ft.account_id = a.account_id
    group by 1,2,3,4,5,6,7
)

select * from vat_summary
order by period_year, period_month, net_vat_payable desc