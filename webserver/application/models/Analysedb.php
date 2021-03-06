<?php

use \jlawrence\eos\Parser;

class Analysedb extends CI_Model {
        
    function __construct()
    {
        // Construct the parent class
        parent::__construct();
        $this->load->database();
    }

    public function client_add($client_name)
    {

        $this->db->set('client_short_name', $client_name);
        $this->db->set('client_name', $client_name);
        
        $retval = $this->db->insert('client');
        $last_id = $this->db->insert_id();

        return array($retval, $last_id);
    }

    public function client_delete($client) {
        // step one is to delete all of the instances on the host

        $client_id = $this->client_id_get($client);

        $hosts = $this->hosts_get($client);

        foreach ($hosts as $row) {
            if ( ! $this->host_delete($client, $row->host_name)) {
                return;
            }
        }

        $sql = "delete from client where id = ?";

        // step two is to delete the host
        $result = $this->db->query($sql, array($client_id));

        return $result;
    }

    //check if the client exists
    public function client_exists_client_short_name($client) {
        
        $sql = "select count(*) as countr 
        from client 
        where client.client_short_name = ?";

        $query = $this->db->query($sql, array($client));
        $row = $query->row();
        $retval = $row->countr;

        return $retval > 0;
    }

    public function client_id_get($client_name) {
        
        $sql = "SELECT id FROM client where client_name = ? order by client_name";
        $query = $this->db->query($sql, array($client_name)); 
        
        return $query->row()->id;
    }

    public function clients_get()
    {
        $query = $this->db->get('client');
        return $query->result();
    }

    public function client_update_names($client_old, $client_new) {

        $client_id = $this->client_id_get($client_old);

        $this->db->where('id', $client_id);
        $this->db->set('client_short_name', $client_new);
        $this->db->set('client_name', $client_new);
        $retval = $this->db->update('client');

        return $retval;
    }

    // delete the date 
    public function date_delete($instanceid, $date) {

        // delete the partiton from the table corresponding to a particular date 

        // ok first this is to get the table 
        $table = "metric_data_" . $instanceid;
        // get the partition name 
        $partition = $this->date_to_partition($date);

        // Ok - let's drop the partition
        $sql = "ALTER TABLE $table DROP PARTITION $partition";

        return $this->db->query($sql); 
    }

    // date to partition 
    // converts a value from a date to a partition
    public function date_to_partition($date) {
        $retval="p" . substr($date, 0, 4) . substr($date, 5, 2) . substr($date, 8, 2);

        return $retval;
    }

    // get the dates 
    public function dates_get($instanceid) {

        $sql = "SELECT partition_name FROM information_schema.partitions where table_name = ? and table_rows > 0 order by partition_name desc";
        
        $table_name = "metric_data_" . $instanceid;
        
        $query = $this->db->query($sql, array($table_name));

        $dates = [];

        foreach ($query->result() as $row) {
            //var_dump($row);
            $date = substr($row->PARTITION_NAME, 1,4) . "-" . substr($row->PARTITION_NAME, 5, 2) . "-" . substr($row->PARTITION_NAME, 7, 2);
            array_push($dates, $date);
        }

        return $dates;
    }
    
    public function graphs_get() {
        $sql = "SELECT * FROM graph order by graph_order";
        $query = $this->db->query($sql); 
    
        return $query->result();
    }
    
    public function host_add($client, $host_name)
    {
        $client_id = $this->client_id_get($client);

        $this->db->set('host_short_name', $host_name);
        $this->db->set('host_name', $host_name);
        $this->db->set('client_id', $client_id);
        
        $retval = $this->db->insert('host');
        $last_id = $this->db->insert_id();

        return array($retval, $last_id);
    }
    
    public function host_delete($client, $host) {
        // step one is to delete all of the instances on the host

        $client_id = $this->client_id_get($client);

        $sql = "select id from host where client_id = ? and host_name = ?";

        $query = $this->db->query($sql, array($client_id, $host));

        $hostid = $query->row()->id;

        $sql2 = "select id from instance where host_id = ?";

        $query2 = $this->db->query($sql2, array($hostid));

        foreach ($query2->result() as $row) {
            if (! $this->instance_delete($row->id)) {
                return false;
                break;
            }
        }

        $sql3 = "delete from host where id = ?";

        // step two is to delete the host
        $result = $this->db->query($sql3, array($hostid));
        return $result;
    }
    
    public function host_exists_host_short_name($client, $host) {
        
        $sql = "select count(*) as countr 
        from host, client 
        where host_short_name = ? 
        and host.client_id = client.id 
        and client.client_short_name = ?";

        $query = $this->db->query($sql, array($host, $client));
        $row = $query->row();
        $retval = $row->countr;

        return $retval > 0;
    }

    public function hosts_get($client)
    {
        $client_id = $this->client_id_get($client);

        $this->db->where("client_id", $client_id);
        $this->db->order_by("host_name");
        $query = $this->db->get('host');
        return $query->result();
    }


    public function host_id_get($host_name, $client_name) {
    
        $client_id = $this->client_id_get($client_name);

        $sql = "SELECT id FROM host where host_name = ? and client_id = ?";
        $query = $this->db->query($sql, array($host_name, $client_id)); 

        return $query->row()->id;
    }

    public function host_update_names($client, $host_old, $host_new) {

        $client_id = $this->client_id_get($client);

        $this->db->where('client_id', $client_id);
        $this->db->where('host_short_name', $host_old);
        $this->db->set('host_short_name', $host_new);
        $this->db->set('host_name', $host_new);
        $retval = $this->db->update('host');

        return $retval;
    }

    public function instance_add($instance_name, $host_name, $client_name)
    {
        
        $host_id=$this->analysedb->host_id_get($host_name, $client_name);

        $this->db->set('instance_name', $instance_name);
        $this->db->set('host_id', $host_id);
        
        $retval = $this->db->insert('instance');
        $last_id = $this->db->insert_id();

        return array($retval, $last_id);
    }

    

    // delete the date 
    public function instance_delete($instanceid) {

        // delete the table corresponding to the partition 

        // ok first this is to get the table 
        $table = "metric_data_" . $instanceid;
        
        // Ok - let's drop the partition

        $sql2 = "DELETE FROM instance WHERE id = ?";

        try {
            $query2 = $this->db->query($sql2, array($instanceid));
        } catch (Exception $e) {

        }

        $sql = "DROP TABLE IF EXISTS $table";

        return $this->db->query($sql); 
    }

    public function instance_exists_name($client, $host, $instance) {
        
        $sql = "select count(*) as countr 
        from instance, host, client 
        where instance_name = ? 
        and host.id = instance.host_id 
        and host_short_name = ? 
        and host.client_id = client.id 
        and client.client_short_name = ?";

        $query = $this->db->query($sql, array($instance, $host, $client));
        $row = $query->row();
        $retval = $row->countr;

        return $retval > 0;
    }

    public function instances_get($host, $client)
    {
        
        $host_id = $this->host_id_get($host, $client);

        $this->db->where("host_id", $host_id);
        $this->db->order_by("instance_name");
        $query = $this->db->get('instance');
        return $query->result();
    }


    public function instance_update_name($id, $name) {

        $this->db->where('id', $id);
        $this->db->set('instance_name', $name);
        $retval = $this->db->update('instance');

        return $retval;
    }
    
    public function metric_get($instanceid, $metric_id, $date) {
        $sql = "SELECT metric_date, data FROM metric_data_".$instanceid." where instance_id = ? and metric_header_id = ? and DATE(metric_date) = ? order by metric_date";
        $query = $this->db->query($sql, array($intanceid, $metric_id, $date)); 

        return $query->result();
    }

    public function metric_json_get($instanceid, $metric_id, $date) {

        $metric_name = metricheadername_get($metric_id);

        $sql = "SELECT metric_date, data->>'$.'" + $metric_name +  "' FROM metrics where instance_id = ? DATE(metric_date) = ? order by metric_date";
        $query = $this->db->query($sql, array($intanceid, $metric_id, $date));
        
        return $query->result();
    
    }

    public function metricheadername_get($metric_id) {

        $sql = "SELECT metric_name FROM metric_header where id = ?";
        $query = $this->db->query($sql, array($metric_id)); 

        return $query->row()->metric_name;
    }        

    public function metricheaderid_get($metric_name) {

        $sql = "SELECT id FROM metric_header where metric_name = ?";
        $query = $this->db->query($sql, array($metric_name)); 

        return $query->row()->id;
    }        

    public function series_get($graph_id, $instanceid, $targetdate) {
        
        $this->db->reconnect();
        
        $sql = "SELECT * FROM series left outer join series_set ON id = series_id where graph_id = ?";
        $query = $this->db->query($sql, array($graph_id));

        $returnset = [];

        $table_name = "metric_data_" . $instanceid;
        $querytype="select";

        foreach ($query->result() as $series_row) {
            
            if (stripos($series_row->series_sql, "call" ) === 0) {
                $querytype="call";
            } else {
                $querytype="select";
            }

            $ssql = str_replace( "metric_data", $table_name, $series_row->series_sql);

            $set_array = [];
            $set_label = [];
            $isset = false;
            if ($series_row->sql != NULL) {
                $setquery = $this->db->query($series_row->sql);
                foreach ($setquery->result() as $header) {
                    array_push($set_array, $header->metric_name);
                    if ($header->label != NULL) {
                        array_push($set_label, $header->label);
                    } else {
                        array_push($set_label, $header->metric_name);
                    }
                }
                $isset = true;
            } else {
                array_push($set_array, "once");
            }

            foreach ($set_array as $key=>$metric_header)
            {
                $retobj = new \stdClass();
                $retobj->series_type = $series_row->series_types_name;
                $retobj->average = $series_row->average;
                $retobj->series_label = $series_row->series_label;
                
                //return $ssql;
                if ($isset) {
                    $s_query = $this->db->query($ssql, array($targetdate, $metric_header));
                    $retobj->series_label = $set_label[$key];
                } else {
                    $s_query = $this->db->query($ssql, array($targetdate));
                }
                
                $metrics = [];
                foreach ($s_query->result() as $row) {
                    $metric = new \stdClass();
                    $metric->date = $row->metric_date;
                    $metric->datum = $row->data;
                    array_push($metrics, $metric);
                }
                
                if ($querytype === "call") {
                    $s_query->next_result();
                }
                
                $s_query->free_result();

                if (count($metrics) > 0) {
                    $retobj->data = $metrics;
                    array_push($returnset, $retobj);
                } 
            }
        }
        
        $query->free_result();

        return $returnset;   
    }
    
    public function seriesjson_get($graph_id, $instanceid, $targetdate) {
        
        $this->db->reconnect();
        
        # ----- TO DO --- Currently ignoring series sets ---- needs to be added back or redesigned ------
        #$sql = "SELECT * FROM series_json left outer join series_set ON id = series_id where graph_id = ?";
        $sql = "SELECT * FROM series_json where graph_id = ?;";
        
        $query = $this->db->query($sql, array($graph_id));

        $returnset = [];
        

        $table_name = "metrics";
        $querytype="select";

        $ssql = "select * from metrics where DATE(mdate) = ? and instance = ?";

        $qr = $query->result();

        foreach ($qr as $series_row) {
            
            if (stripos($series_row->calc, "call" ) === 0) {
                $querytype="call";
            } else {
                $querytype="select";
            }

            $metrics = [];
            $set_array = [];
            $set_label = [];
            $isset = false;

            # ---- TO DO ---- More series set stuff to put back
            if ($series_row->action == "matches") {
            
                $mhsql = "select name from metric_header_json where name REGEXP ? and instance_id = ?";
                $mhquery = $this->db->query($mhsql, array($series_row->calc, $instanceid));

                foreach ($mhquery->result() as $field) {
                    $metrics[$field] = [];

            #    $setquery = $this->db->query($series_row->sql);
            #    foreach ($setquery->result() as $header) {
            #        array_push($set_array, $header->metric_name);
            #        if ($header->label != NULL) {
            #            array_push($set_label, $header->label);
            #        } else {
            #            array_push($set_label, $header->metric_name);
            #        }
                 }
                 $isset = true;

            } else {
                
                $metrics['once'] = [''];

                array_push($set_array, "once");
            }
            
            foreach ($set_array as $key=>$metric_header)
            {
                $row = 0;
                $retobj = new \stdClass();
                $retobj->series_type = $series_row->series_types_name;
                $retobj->average = $series_row->average;
                $retobj->series_label = $series_row->series_label;
                
                $s_query = $this->db->query($ssql, array($targetdate, $instanceid));
                
                //$eq = new eqEOS();
                
                //return $ssql;
                
                $var=$series_row->calc;
                $metrics = [];
                foreach ($s_query->result() as $row) {
                    
                    $row = $row + 1;
                    $json = json_decode($row->data); 
                    $metric = new \stdClass();
                    $metric->date = $row->mdate;

                    if ($isset && $row == 1) {
                        $s_query = $this->db->query($ssql, array($targetdate, $metric_header));
                        
                        #set up the arrays and values 
                        foreach ($json as $key => $value) {
                            #--------------------------------------------------############# Work Here ###############
                            #if ($key )
                            #echo "$key => $value\n";
                        }

                        $retobj->series_label = $set_label[$key];
                    } else {
                        //$sql = str_replace(':', 'data->"$', $series_row->calc);
                        //$sql = "Select mdate, data from metrics where mdate = ? and instance = ?";
                        
                        //print $sql;
                    }

                    switch ($series_row->action) {
                        case "equals":
                            //$metric->datum =  ${$series_row->calc};
                            $metric->datum =  $json->$var;
                            array_push($metrics, $metric);
                            break;

                        case "solve":
                            $metric->datum = eval ('return '.$series_row->calc .";");
                            array_push($metrics, $metric);
                            break;
                        case "matches":
                            foreach ($json as $key => $value) {
                                echo "$key => $value\n";
                            }
                                
                            array_push($metrics, $metric);

                        default:
                            $metric->datum = 0;
                    }
                    #$metric->datum = $json_obj->{$series_row->calc};
                    #$metric->datum = Parser::SolveIF($json->{$series_row->calc});     
                }
                
                if ($querytype === "call") {
                    $s_query->next_result();
                }
                
                $s_query->free_result();

                if (count($metrics) > 0) {
                    $retobj->data = $metrics;
                    array_push($returnset, $retobj);
                } 
            }
        }
        
        $query->free_result();

        return $returnset;   
    }

}

?>