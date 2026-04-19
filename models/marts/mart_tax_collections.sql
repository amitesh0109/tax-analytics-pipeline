with ft as (
    select * from {{ ref('stg_ft_ledger') }}
),

periods as (
    select * from {{ ref('stg_tax_period') }}
),

collections as (
    select
        ft.tax_type_cd,
        ft.period_id,
        p.period_year,
        p.period_month,
        p.due_date,

        sum(ft.billed_amount)                    as total_billed,
        sum(ft.payment_amount)                   as total_collected,
        sum(ft.penalty_amount)                   as total_penalties,
        sum(ft.adjustment_amount)                as total_adjustments,

        sum(ft.billed_amount)
            - sum(ft.payment_amount)             as outstanding_balance,

round(
    CAST(sum(ft.payment_amount)
    / nullif(sum(ft.billed_amount), 0)
    * 100 AS NUMERIC), 2)              as collection_rate_pct

    from ft
    left join periods p on ft.period_id = p.period_id
    where ft.ft_type_cd in ('BILL','PAY','PEN','ADJ')
    group by 1,2,3,4,5
)

select * from collections
order by period_year, period_month, tax_type_cd