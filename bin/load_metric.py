from __future__ import print_function
from decimal import Decimal
from datetime import datetime, date, timedelta
from pathlib import Path
from os.path import basename

import mysql.connector
import sys, getopt
import time
import gzip
import csv

def is_number(s):
  try:
    float(s)
  except ValueError:
    return False
  return True

# file name needs to be passed in, but for our initial dev


# this needs to be passed in to the module but we can fudge it for now

# need to add error handling

def get_connection():

  mydb = mysql.connector.connect(
      host="localhost",
      user="analyseifx",
      password="natrium11",
      database="analyseifx",
      auth_plugin='mysql_native_password'
    )

  return mydb

def get_client_id(client_short_name):

  try:
    # need to add error handling
    mydb = get_connection()

    mycursor = mydb.cursor(buffered=True)
    # get the client id - if the client does not exist then create it - use the short name for the long name
    sql = "select id from client where client_short_name = %s"

    v = (client_short_name,)

    mycursor.execute(sql, v)
    
    if mycursor.rowcount == 0:
      sql="insert into client (client_name, client_short_name) values (%s, %s);"

      v = ( client_short_name , client_short_name)

      mycursor.execute(sql, v)
      mydb.commit()

      return mycursor.lastrowid
    else:
      # need to add error handling
      return mycursor.fetchone()[0]

  except mysql.connector.Error as e:
        print(e)
        return None
  finally:
    mycursor.close()
    mydb.close()

def get_host_id (client_id, hostname):

  try:      
    # get the host id. if the host does not exist then create it
  
    mydb = get_connection()

    mycursor = mydb.cursor(buffered=True)
    
    sql = "SELECT id FROM host where client_id = %s and host_short_name = %s "

    v = (client_id, hostname)

    mycursor.execute(sql, v)

    if mycursor.rowcount == 0:
      sql = "INSERT INTO host (host_short_name,host_name,client_id) VALUES ( %s, %s, %s)"
        
      v = (hostname, hostname, client_id)
      mycursor.execute(sql, v)
      mydb.commit()
      return mycursor.lastrowid
    else:
      # need to add error handling
      return mycursor.fetchone()[0]

  except mysql.connector.Error as e:
    print(e)
    return None
  finally:
    mycursor.close()
    mydb.close()

def get_instance_id (host_id, instance):

  try:      
    # get the host id. if the host does not exist then create it
  
    mydb = get_connection()

    mycursor = mydb.cursor(buffered=True)
    
    sql = "SELECT id FROM instance where host_id = %s and instance_name = %s "

    v = (host_id, instance)

    mycursor.execute(sql, v)

    if mycursor.rowcount == 0:
      sql = "INSERT INTO instance (host_id, instance_name) VALUES ( %s, %s)"
        
      mycursor.execute(sql, v)

      # we also need to create the metric_data table
      instance_id = mycursor.lastrowid

      sql = "CREATE TABLE IF NOT EXISTS `analyseifx`.`metric_data_" + str(instance_id) + """` (
        `metric_date` DATETIME NOT NULL,
        `data` DECIMAL(19,2) NOT NULL,
        `metric_header_id` INT NOT NULL,
        `instance_id` INT NOT NULL,
        `seq_no` INT NOT NULL,
        PRIMARY KEY (`metric_date`, `metric_header_id`, `instance_id`),
        INDEX `fk_metric_data_metric_header1_idx` (`metric_header_id` ASC),
        INDEX `metric_date` (`metric_date` ASC),
        INDEX `fk_metric_data_instance_id_idx` (`instance_id` ASC),
        INDEX `ix_metric_date_header_seq` (`seq_no`, `metric_date`, `metric_header_id`))
        ENGINE = InnoDB
        PARTITION BY LIST(to_days(metric_date)) (
          PARTITION p""" + time.strftime('%Y%m%d') + " VALUES IN (to_days('" +  time.strftime('%Y-%m-%d') + "')));"
      print(sql)
      mycursor.execute(sql)
      mydb.commit()
      return instance_id
    else:
      # need to add error handling
      return mycursor.fetchone()[0]

  except mysql.connector.Error as e:
    print(e)
    mydb.rollback()
    return None
  finally:
    mycursor.close()
    mydb.close()

def get_metric_ids(headings):

  try:      
    # get the host id. if the host does not exist then create it
  
    mydb = get_connection()

    mycursor = mydb.cursor(buffered=True)
    myinscursor = mydb.cursor()
    metric_ids = []
    
    ssql = "select id from metric_header where metric_name = %s"
    isql = "insert into metric_header (metric_name, label) values (%s, %s)"
  
    for heading in headings:
    
      v = (heading,)
      w = (heading, heading)
      
      mycursor.execute(ssql, v)

      if mycursor.rowcount == 0:
        print ("Add header " + heading)
        # need to add error handling
        myinscursor.execute(isql, w)
        mydb.commit()
        metric_id = myinscursor.lastrowid
      else:
        # need to add error handling
        metric_id = mycursor.fetchone()[0]

      metric_ids.append(metric_id)

    return metric_ids

  except mysql.connector.Error as e:
    print(e)
    return None
  finally:
    mycursor.close()
    mydb.close()
  
def addpartition (partdate, instance_id):

  try:      
    # get the host id. if the host does not exist then create it
  
    mydb = get_connection()
    pdate="20"+partdate[2] + partdate[1] + partdate[0]

    mycursor = mydb.cursor(buffered=True)
    
    sql = "select partition_name from information_schema.partitions where table_name = %s and partition_name = %s"
    

    table_name = "metric_data_" + str(instance_id)
    partition = "p" + pdate

    v = (table_name, partition)
    mycursor.execute(sql, v)

    if mycursor.rowcount == 0:
      sql = "alter table " + table_name + " add partition (partition " + partition + " values in (to_days('" + pdate + "')));"
      print (sql + " " + partition + " " + pdate)
  
      
      mycursor.execute(sql)
      mydb.commit()
      
  except mysql.connector.Error as e:
    print(e)
    return None
  finally:
    mycursor.close()
    mydb.close()

def main(argv):

  try:
    opts, args = getopt.getopt(argv,"hc:s:i:f:",["client=","host=","instance=","file="])
  except getopt.GetoptError:
    print (PROGNAME + ' -c <client> -s <host> -i <instance> -f <filename>')
    sys.exit(2)

  for opt, arg in opts:
    if opt == '-h':
      print (PROGNAME + ' -c <client> -s <host> -i <instance> -f <filename>')
      sys.exit()
    elif opt in ("-c", "--client"):
      client = arg
    elif opt in ("-s", "--host"):
      host=arg
    elif opt in ("-i", "--instance"):
      instance=arg
    elif opt in ("-f", "--file"):
      filename=arg
      
  if len(sys.argv) < 8:
    print (PROGNAME + ' -c <client> -s <host> -i <instance> -f <filename>')
    sys.exit()

  # let us check if the file exists
  print ("Checking file path")
  file_exists = Path(filename)

  try:
    file_exists.resolve()
  except FileNotFoundError:
    sys.exit("File not found")

  print ("Getting the client id")
  client_id = get_client_id(client)
  print("Getting the host id")
  host_id = get_host_id(client_id, host)
  print("Getting the instance id")
  instance_id = get_instance_id (host_id, instance)

  print("Processing the file - open")
  f = gzip.open(filename, "rt")


  reader = csv.reader(f, delimiter='|')
  # get the headings from the file 
  headings = next(reader)
  print(headings)
  #headings = line.split("|")

  metric_ids =  get_metric_ids(headings)

  SQL="insert ignore into metric_data_%s(metric_date, instance_id, metric_header_id, seq_no, data) values ( %s , %s, %s , %s, %s )"

  try:
    mydb = get_connection()

    mycursor = mydb.cursor(buffered=True)
    
    filedate_set = False

    counter = 0

    filedate = ""

    for fields in reader:
      counter = counter + 1
      
      #print(fields)

      fdate = fields[0].split("/")
      metricdatetime = "20" + fdate[2] + "-" + fdate[1] + "-" + fdate[0] + " " + fields[1]

      if filedate_set == False:
        partdate=fdate
        addpartition(fdate, instance_id)
        filedate_set = True
        filedate=fields[0]
      
      if partdate != fdate:
        partdate = fdate
        addpartition(fdate, instance_id)

      print(metricdatetime)
      
      for i, field in enumerate(fields):      
        if is_number(field):    
          v = (instance_id, metricdatetime, instance_id, metric_ids[i], counter, field)    
          #error handling
          mycursor.execute(SQL, v) 

      mydb.commit()

    #SQL="INSERT INTO `analyseifx`.`row_sequence` (`instance_id`,`date`,`counter`) VALUES (%s, %s, %s)"

    #v=(instance_id, filedate, counter)

    #mycursor.execute(SQL, v)
  except mysql.connector.Error as e:
    print(e)
  finally:
    mycursor.close()
    mydb.close()

PROGNAME = sys.argv[0]

if __name__ == "__main__":
   main(sys.argv[1:])
