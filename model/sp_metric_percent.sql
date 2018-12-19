delimiter $$

drop procedure if exists metric_delta_percent ;

create  procedure metric_delta_percent ( 
    IN pdate date, 
    IN pmetric1 varchar(45), 
    IN pmetric2 varchar(45), 
    IN ptable varchar(45))
BEGIN

    DECLARE xdone INT DEFAULT FALSE;
    DECLARE v_seq_no INT;
    DECLARE v_data1 DECIMAL(19,2);
    DECLARE v_data2 DECIMAL(19,2);
    DECLARE v_metric_date DATETIME;
    DECLARE xbase1 DECIMAL(19,2);
    DECLARE xbase2 DECIMAL(19,2);
    DECLARE y_data1 DECIMAL(19,2);
    DECLARE y_data2 DECIMAL(19,2);
    DECLARE y_keep DECIMAL(19,2) DEFAULT 100;
    DECLARE y_calc DECIMAL(19,2);
    
    SET @enabled = FALSE;
    
    create temporary table if not exists x (metric_date datetime, seq_no int, datum1 decimal(19,2), datum2 decimal(19,2)) engine = memory;
    create temporary table if not exists y (metric_date datetime, seq_no int, data decimal(19,2)) engine = memory;
    
    SET @table = ptable;
    
    SET @select = concat('
		INSERT INTO x (metric_date, seq_no, datum1, datum2) 
		SELECT d2.metric_date, d2.seq_no, d1.data, d2.data 
		FROM metric_header h1, ',  @table, ' AS d1, metric_header h2, ', @table, ' AS d2
		WHERE h1.id = d1.metric_header_id
		AND h1.metric_name = ?
		AND h2.id = d2.metric_header_id
		AND h2.metric_name = ?
        AND date(d1.metric_date) = ?
        AND d1.metric_date = d2.metric_date;
		');
        

    prepare stm from @select;
   
    
    
    set @metric1 = pmetric1;
    set @metric2 = pmetric2;
    set @vdate = pdate;
	EXECUTE stm USING @metric1, @metric2, @vdate;
    
    DEALLOCATE PREPARE stm;

    BEGIN
    
		DECLARE cursorforx CURSOR FOR
		SELECT metric_date, seq_no, datum1, datum2 
		FROM x 
        ORDER BY seq_no;
		
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET xdone = TRUE;
	
		OPEN cursorForx;  
	 
		read_loop: LOOP
	
			FETCH cursorForx INTO v_metric_date, v_seq_no, v_data1, v_data2;
            
			IF xdone THEN
				LEAVE read_loop;
			END IF;
		   
			IF v_seq_no > 1 THEN
				SET y_data1 = v_data1 - xbase1;
                SET y_data2 = v_data2 - xbase2;
                SET xbase1 = v_data1;
                SET xbase2 = v_data2;
                
                
                IF y_data1 = 0 THEN
                    SET y_calc = y_keep;
				ELSE
					SET y_calc =  (y_data1 - y_data2) / y_data1 * 100;
                
					IF y_calc < 0 THEN
						SET y_calc = y_keep;
					END IF;
				END IF;
				INSERT INTO y (metric_date, seq_no, data) VALUES (v_metric_date, v_seq_no, y_calc);
			END IF;
            
            SET xbase1 = v_data1;
			SET xbase2 = v_data2;
	
		END LOOP;
		COMMIT;
	  
		CLOSE cursorForx;
	END;
    
    SELECT * FROM y;
  
    DROP TABLE x;
    DROP TABLE y;
    
   
END$$

delimiter ;