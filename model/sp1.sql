delimiter $$

drop procedure if exists metric_delta ;
drop procedure if exists debug_msg ;

CREATE PROCEDURE debug_msg(enabled INTEGER, msg VARCHAR(255))
BEGIN
  IF enabled THEN BEGIN
    select concat("** ", msg) AS '** DEBUG:';
  END; END IF;
END $$

create  procedure metric_delta ( 
    IN pdate date, 
    in pmetric varchar(45), 
    in pinstance int)
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
    
    call debug_msg(@enabled, "1");
    SET @table = concat("metric_data_", pinstance);
    
    SET @select = concat('INSERT INTO x (seq_no, datum) SELECT seq_no, data from ', @table,  ' where date(metric_date) = ? and metric_header_id = ?');
    
    #select @select;
    call debug_msg(@enabled, "2");
    prepare stm from @select;
   
    SET @vdate = pdate;
    SET @id = metric_header_id;
	call debug_msg(@enabled, "3");
	EXECUTE stm USING @vdate, @id;
   
    BEGIN
    
		DECLARE cursorforx CURSOR FOR
		SELECT seq_no, datum 
		FROM x 
        ORDER BY seq_no;
		
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET xdone = TRUE;
		#call debug_msg(@enabled, "4");   
		OPEN cursorForx;  
	 
		read_loop: LOOP
			#call debug_msg(@enabled, "5");
			FETCH cursorForx INTO v_seq_no, v_data;
            
			IF xdone THEN
				LEAVE read_loop;
			END IF;
		   
			IF v_seq_no = 1 THEN
				SET xbase = v_data;
			ELSE
				#call debug_msg(@enabled, "6");
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