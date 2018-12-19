

SELECT 
    h1.*,
    d2.metric_date,
    ((d2.data - d1.data) - (d4.data - d3.data)) / (d2.data - d1.data) * 100
FROM
    metric_header h1,
    metric_data_4 PARTITION (p20181027) AS d1,
    metric_data_4 PARTITION (p20181027) AS d2,
    
    metric_header h2,
    metric_data_4 PARTITION (p20181027) AS d3,
    metric_data_4 PARTITION (p20181027) AS d4
WHERE
    h1.id = d1.metric_header_id
     #   AND DATE(d1.metric_date) = '2018-10-27'
        AND h1.metric_name = 'bufwrits'
        AND h1.id = d2.metric_header_id
     #   AND DATE(d2.metric_date) = DATE(d1.metric_date)
        AND d1.seq_no = d2.seq_no - 1
        AND h2.id = d3.metric_header_id
        AND d3.metric_date = d1.metric_date
        AND h2.metric_name = 'dskwrits'
        AND h2.id = d4.metric_header_id
        AND d4.metric_date = d2.metric_date
        AND (((d2.data - d1.data) - (d4.data - d3.data)) / (d2.data - d1.data) * 100) > 0

;
#select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = "dskread
#ANALYZE TABLE metric_data_4;
#ANALYZE TABLE metric_header;
#OPTIMIZE TABLE metric_data_4;