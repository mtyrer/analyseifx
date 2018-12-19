delimiter $$

drop procedure if exists metric_delta ;

create  procedure metric_delta ( 
    IN pdate date, 
    in pmetric varchar(45), 
    in ptable varchar(45)
BEGIN

    DECLARE metric_header_id int;
    DECLARE delta int;
    DECLARE xdone INT DEFAULT FALSE;
    DECLARE v_seq_no INT;
    DECLARE v_data DECIMAL(19,2);
    DECLARE xbase DECIMAL(19,2);
    DECLARE y_data DECIMAL(19,2);
    
    SET @enabled = FALSE;
    
    #select pmetric;
    
    create temporary table if not exists x ( seq_no int, datum decimal(19,2)) engine = memory;
    create temporary table if not exists y ( seq_no int, datum decimal(19,2)) engine = memory;
    
    select id into metric_header_id from metric_header where metric_name = pmetric; 
    
    SET @table = ptable;
    
    SET @select = concat('INSERT INTO x (seq_no, datum) SELECT seq_no, data from ', @table,  ' where date(metric_date) = ? and metric_header_id = ?');
    
    #select @select;
    prepare stm from @select;
   
    SET @vdate = pdate;
    SET @id = metric_header_id;

	EXECUTE stm USING @vdate, @id;
   
    BEGIN
    
		DECLARE cursorforx CURSOR FOR
		SELECT seq_no, datum 
		FROM x 
        ORDER BY seq_no;
		
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET xdone = TRUE;

		OPEN cursorForx;  
	 
		read_loop: LOOP

			FETCH cursorForx INTO v_seq_no, v_data;
            
			IF xdone THEN
				LEAVE read_loop;
			END IF;
		   
			IF v_seq_no = 1 THEN
				SET xbase = v_data;
			ELSE

				SET y_data = v_data - xbase;
                SET xbase = v_data;
				INSERT INTO y (seq_no, datum) VALUES (v_seq_no, y_data);
			END IF;
	
		END LOOP;
		COMMIT;
	  
		CLOSE cursorForx;
	END;
    
    SELECT * FROM y;
  
    DROP TABLE x;
    DROP TABLE y;
    DEALLOCATE PREPARE stm;
   
END$$

delimiter ;