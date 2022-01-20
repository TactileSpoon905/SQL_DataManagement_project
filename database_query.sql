/**
 The following query was contributed to implement for data management process 
 improvement to save ~ 0.11 Full Time Employee Work-over-Week productivity. 
 Database names and records sole purpose of GitHub repository showcasing. 
 All data is fully owned and managed by Amazon Hubble team and remains 
 property of Amazon and AWS.     
**/

SELECT tab_1.asin, tab_1.gtin, tab_1.gtin_status, tab_1.brand_id,
tab_1.brand_name, tab_1.sell_through_date, tab_1.NTM_TID,

CASE WHEN tab_1.tpncy_status ='ONBOARDED' THEN 'YES'
WHEN tab_1.tpncy_status = 'OFFBOARDED' THEN 'NO'
END AS is_onboarded, tab_1.team, tab_1.Test_Buy

FROM (
SELECT DISTINCT a.asin, c.tpncy_status, a.gtin, a.gtin_status, a.is_deleted, c.legacy_vendor_code AS brand_id,
        c.brand_name, d.sales_team AS team, e.actions_taken AS Test_Buy, sell_through_date, NTM_TID
    FROM o_amzn_products_lc a
        LEFT JOIN
        (SELECT z.asin, gtin, sell_through_date, target_ib_date as NTM_TID
        FROM
            ( SELECT
        asin
        , gtin
        , sell_through_date
        , ROW_NUMBER () OVER (PARTITION BY asin ORDER BY last_modified_time DESC) AS rnk
            FROM public.o_amzn_products_lc_audit
    ) z
            LEFT JOIN
            (SELECT DISTINCT asin, opr_turn_on_date, target_ib_date
            FROM TPNCY_REPORT.NEW_TO_MARKET_PRODUCTS
    ) y
        ON z.ASIN = y.ASIN
        WHERE z.rnk = 1
) b
        ON a.asin = b.asin
        LEFT JOIN d_tpncy_products c
        ON a.gtin=c.gtin_list
        LEFT JOIN public.v_transparency_account d
        ON c.billing_entity_tpncy_id = d.account_id
        LEFT JOIN tpncy_report.test_buy_program_v2 e
        ON a.asin = e.asin
) tab_1

WHERE tab_1.asin IN (<"paste asin number here">)
AND tab_1.is_deleted='false'
ORDER BY tab_1.NTM_TID