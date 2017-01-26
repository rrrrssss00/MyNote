不使用存储过程
select * from xxx where aaa is not null and regexp_like (str, '^(-{0,1}+{0,1})[0-9]+(.{0,1}[0-9]+)$')

使用存储过程：
select isnumeric('123.509') from dual;
1. 利用 to_number
CREATE OR REPLACE FUNCTION isnumeric (str IN VARCHAR2)
    RETURN NUMBER
IS
    v_str FLOAT;
BEGIN
    IF str IS NULL
    THEN
       RETURN 0;
    ELSE
       BEGIN
          SELECT TO_NUMBER (str)
            INTO v_str
            FROM DUAL;
       EXCEPTION
          WHEN INVALID_NUMBER
          THEN
             RETURN 0;
       END;

       RETURN 1;
    END IF;
END isnumeric;


2. 利用 regexp_like 
CREATE OR REPLACE FUNCTION isnumeric (str IN VARCHAR2)
    RETURN NUMBER
IS
BEGIN
    IF str IS NULL
    THEN
       RETURN 0;
    ELSE
       IF regexp_like (str, '^(-{0,1}+{0,1})[0-9]+(.{0,1}[0-9]+)$')
       THEN
          RETURN 1;
       ELSE
          RETURN 0;
       END IF;
    END IF;
END isnumeric;


3. 利用 TRANSLATE
CREATE OR REPLACE FUNCTION isnumeric (str IN VARCHAR2)
    RETURN NUMBER
IS
    v_str VARCHAR2 (1000);
BEGIN
    IF str IS NULL
    THEN
       RETURN 0;
    ELSE
       v_str := TRANSLATE (str, '.0123456789', '.');

       IF v_str = '.' OR v_str = '+.' OR v_str = '-.' OR v_str IS NULL
       THEN
          RETURN 1;
       ELSE
          RETURN 0;
       END IF;
    END IF;
END isnumeric;

来源： <http://www.itpub.net/thread-867122-1-1.html>
 

