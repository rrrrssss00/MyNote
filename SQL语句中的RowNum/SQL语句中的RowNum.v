select * from 
(
    SELECT A.*, ROWNUM RN FROM 
        (select * from dxt_zjz100w a where a.old_number in ('A-49') 
        union select * from dxt_zjz50w b where b.old_number in ('A-49-D','A-49-C','A-49-B','A-49-A') )
    A 
) 
where RN >1 and RN <3
 
注意，这里，如果用
SELECT A.*, ROWNUM RN FROM 
        (select * from dxt_zjz100w a where a.old_number in ('A-49') 
        union select * from dxt_zjz50w b where b.old_number in ('A-49-D','A-49-C','A-49-B','A-49-A') )
    A where ROWNUM >1 and ROWNUM<3

