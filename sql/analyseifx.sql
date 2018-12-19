-- MySQL dump 10.13  Distrib 8.0.13, for Linux (x86_64)
--
-- Host: localhost    Database: analyseifx
-- ------------------------------------------------------
-- Server version	8.0.13

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8mb4 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `client`
--

DROP TABLE IF EXISTS `client`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `client` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `client_name` varchar(45) COLLATE utf8_bin NOT NULL COMMENT 'name of the client',
  `client_short_name` varchar(45) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `client_name_UNIQUE` (`client_name`),
  UNIQUE KEY `client_short_name_UNIQUE` (`client_short_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client`
--

LOCK TABLES `client` WRITE;
/*!40000 ALTER TABLE `client` DISABLE KEYS */;
INSERT INTO `client` VALUES (1,'nzrb','nzrb');
/*!40000 ALTER TABLE `client` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `file`
--

DROP TABLE IF EXISTS `file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `file` (
  `filename` varchar(255) COLLATE utf8_bin NOT NULL,
  `filedate` date NOT NULL,
  `filedateloaded` date DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `instance_id` int(11) NOT NULL,
  `state` char(1) COLLATE utf8_bin NOT NULL DEFAULT 'G',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_file` (`filedate`,`instance_id`),
  KEY `fk_file_instance1_idx` (`instance_id`),
  CONSTRAINT `fk_file_instance1` FOREIGN KEY (`instance_id`) REFERENCES `instance` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `file`
--

LOCK TABLES `file` WRITE;
/*!40000 ALTER TABLE `file` DISABLE KEYS */;
INSERT INTO `file` VALUES ('nzrb_prepprtidb01_pam_20181027.txt','2018-10-27','2018-11-01',5,8,'G');
/*!40000 ALTER TABLE `file` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `graph`
--

DROP TABLE IF EXISTS `graph`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `graph` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `graph_name` varchar(45) COLLATE utf8_bin NOT NULL,
  `graph_title` varchar(45) COLLATE utf8_bin NOT NULL,
  `graph_order` int(11) NOT NULL,
  `graph_type` enum('FLAT','STACKED') COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `graph_name_UNIQUE` (`graph_name`),
  UNIQUE KEY `order_UNIQUE` (`graph_order`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `graph`
--

LOCK TABLES `graph` WRITE;
/*!40000 ALTER TABLE `graph` DISABLE KEYS */;
INSERT INTO `graph` VALUES (1,'Disk IO','Disk IO',1,'FLAT'),(2,'Cache Hits','Cache Hits',2,'FLAT'),(3,'CPU','User vs System workload',3,'STACKED'),(4,'Sequential Scans','Sequential Scans',4,'FLAT'),(5,'Check Points','Check Points',5,'FLAT'),(6,'Transactions','Transactions',6,'FLAT'),(7,'DeadLocks','DeadLocks',7,'FLAT'),(8,'Sessions','Sessions',8,'FLAT'),(9,'Locks','Locks',9,'FLAT'),(10,'Log Usage','Log Usage',10,'FLAT'),(11,'Threads','Threads',11,'STACKED'),(12,'Network Connections','Network Connections',17,'FLAT'),(13,'Buffer Waits','Buffer Waits',13,'FLAT'),(14,'Memory','Memory',14,'STACKED'),(15,'Log Buffer','Log Buffer',15,'FLAT'),(16,'VP CPUs','VP CPUs',16,'FLAT'),(17,'Network Activity','Netword reads and writes',18,'FLAT'),(18,'Read Ahead','Read Ahead',12,'FLAT');
/*!40000 ALTER TABLE `graph` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `host`
--

DROP TABLE IF EXISTS `host`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `host` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host_short_name` varchar(45) COLLATE utf8_bin NOT NULL COMMENT 'used in file uploads',
  `host_name` varchar(45) COLLATE utf8_bin NOT NULL,
  `client_id` int(11) NOT NULL,
  PRIMARY KEY (`id`,`client_id`),
  UNIQUE KEY `shortname_UNIQUE` (`host_short_name`),
  UNIQUE KEY `host_name_UNIQUE` (`host_name`),
  KEY `fk_host_client1_idx` (`client_id`),
  CONSTRAINT `fk_host_client1` FOREIGN KEY (`client_id`) REFERENCES `client` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `host`
--

LOCK TABLES `host` WRITE;
/*!40000 ALTER TABLE `host` DISABLE KEYS */;
INSERT INTO `host` VALUES (1,'prepprtidb001','prepprtidb001',1);
/*!40000 ALTER TABLE `host` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `instance`
--

DROP TABLE IF EXISTS `instance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `instance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `instance_name` varchar(45) COLLATE utf8_bin NOT NULL,
  `host_id` int(11) NOT NULL,
  PRIMARY KEY (`id`,`host_id`),
  UNIQUE KEY `instance_name_UNIQUE` (`instance_name`),
  KEY `fk_instance_host1_idx` (`host_id`),
  CONSTRAINT `fk_instance_host1` FOREIGN KEY (`host_id`) REFERENCES `host` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `instance`
--

LOCK TABLES `instance` WRITE;
/*!40000 ALTER TABLE `instance` DISABLE KEYS */;
INSERT INTO `instance` VALUES (5,'sport',1);
/*!40000 ALTER TABLE `instance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `metric_data`
--

DROP TABLE IF EXISTS `metric_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `metric_data` (
  `metric_date` datetime NOT NULL,
  `data` decimal(19,2) NOT NULL,
  `metric_header_id` int(11) NOT NULL,
  `instance_id` int(11) NOT NULL,
  PRIMARY KEY (`metric_date`,`metric_header_id`,`instance_id`),
  KEY `fk_metric_data_metric_header1_idx` (`metric_header_id`),
  KEY `metric_date` (`metric_date`),
  KEY `fk_metric_data_instance1_idx` (`instance_id`),
  CONSTRAINT `fk_metric_data_instance1` FOREIGN KEY (`instance_id`) REFERENCES `instance` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_metric_data_metric_header1` FOREIGN KEY (`metric_header_id`) REFERENCES `metric_header` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metric_data`
--

LOCK TABLES `metric_data` WRITE;
/*!40000 ALTER TABLE `metric_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `metric_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `metric_header`
--

DROP TABLE IF EXISTS `metric_header`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `metric_header` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `metric_name` varchar(45) COLLATE utf8_bin NOT NULL,
  `label` varchar(45) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `metric_name_UNIQUE` (`metric_name`)
) ENGINE=InnoDB AUTO_INCREMENT=292 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metric_header`
--

LOCK TABLES `metric_header` WRITE;
/*!40000 ALTER TABLE `metric_header` DISABLE KEYS */;
INSERT INTO `metric_header` VALUES (1,'date','date'),(2,'time','time'),(3,'dskreads','dskreads'),(4,'pagreads','pagreads'),(5,'bufreads','bufreads'),(6,'rcached','rcached'),(7,'dskwrits','dskwrits'),(8,'pagwrits','pagwrits'),(9,'bufwrits','bufwrits'),(10,'wcached','wcached'),(11,'isamtot','isamtot'),(12,'open','open'),(13,'start','start'),(14,'read','read'),(15,'write','write'),(16,'rewrite','rewrite'),(17,'delete','delete'),(18,'commit','commit'),(19,'rollbk','rollbk'),(20,'gp_read','gp_read'),(21,'gp_write','gp_write'),(22,'gp_rewrt','gp_rewrt'),(23,'gp_del','gp_del'),(24,'gp_alloc','gp_alloc'),(25,'gp_free','gp_free'),(26,'gp_curs','gp_curs'),(27,'ovlock','ovlock'),(28,'ovuserthread','ovuserthread'),(29,'ovbuff','ovbuff'),(30,'usercpu','usercpu'),(31,'syscpu','syscpu'),(32,'numckpts','numckpts'),(33,'flushes','flushes'),(34,'bufwaits','bufwaits'),(35,'lokwaits','lokwaits'),(36,'lockreqs','lockreqs'),(37,'deadlks','deadlks'),(38,'dltouts','dltouts'),(39,'ckpwaits','ckpwaits'),(40,'compress','compress'),(41,'seqscans','seqscans'),(42,'ixdaRA','ixdaRA'),(43,'idxRA','idxRA'),(44,'daRA','daRA'),(45,'RApgsused','RApgsused'),(46,'lchwaits','lchwaits'),(47,'sessions','sessions'),(48,'activelocks','activelocks'),(49,'pbuffer','pbuffer'),(50,'pbufused','pbufused'),(51,'pbufsize','pbufsize'),(52,'pnumpages','pnumpages'),(53,'pnumwrits','pnumwrits'),(54,'ppagesio','ppagesio'),(55,'pphybegin','pphybegin'),(56,'pphysize','pphysize'),(57,'pphypos','pphypos'),(58,'pphyused','pphyused'),(59,'pphypcnt','pphypcnt'),(60,'lbuffer','lbuffer'),(61,'lbufused','lbufused'),(62,'lbufsize','lbufsize'),(63,'lnumrecs','lnumrecs'),(64,'lnumpages','lnumpages'),(65,'lnumwrits','lnumwrits'),(66,'lrecspages','lrecspages'),(67,'lpagesio','lpagesio'),(68,'lsubsystem','lsubsystem'),(69,'lsnumrecs','lsnumrecs'),(70,'lsspaceused','lsspaceused'),(71,'lltotalsize','lltotalsize'),(72,'lltotalused','lltotalused'),(73,'shmtotal','shmtotal'),(74,'blkused','blkused'),(75,'blkfree','blkfree'),(76,'threadrea','threadrea'),(77,'threadwai','threadwai'),(78,'threadsle','threadsle'),(79,'netaccept','netaccept'),(80,'netreject','netreject'),(81,'netread','netread'),(82,'netwrite','netwrite'),(83,'sdeclient','sdeclient'),(84,'buffdirty','buffdirty'),(85,'bufftotal','bufftotal'),(86,'ckptreq','ckptreq'),(87,'user1','user1'),(88,'sys1','sys1'),(89,'total1','total1'),(90,'user2','user2'),(91,'sys2','sys2'),(92,'total2','total2'),(93,'user3','user3'),(94,'sys3','sys3'),(95,'total3','total3'),(96,'user4','user4'),(97,'sys4','sys4'),(98,'total4','total4'),(99,'user5','user5'),(100,'sys5','sys5'),(101,'total5','total5'),(102,'user6','user6'),(103,'sys6','sys6'),(104,'total6','total6'),(105,'user7','user7'),(106,'sys7','sys7'),(107,'total7','total7'),(108,'user8','user8'),(109,'sys8','sys8'),(110,'total8','total8'),(111,'user9','user9'),(112,'sys9','sys9'),(113,'total9','total9'),(114,'user10','user10'),(115,'sys10','sys10'),(116,'total10','total10'),(117,'user11','user11'),(118,'sys11','sys11'),(119,'total11','total11'),(120,'user12','user12'),(121,'sys12','sys12'),(122,'total12','total12'),(123,'user13','user13'),(124,'sys13','sys13'),(125,'total13','total13'),(126,'user14','user14'),(127,'sys14','sys14'),(128,'total14','total14'),(129,'user15','user15'),(130,'sys15','sys15'),(131,'total15','total15'),(132,'user16','user16'),(133,'sys16','sys16'),(134,'total16','total16'),(135,'user17','user17'),(136,'sys17','sys17'),(137,'total17','total17'),(138,'\n','\n'),(139,'user18','user18'),(140,'sys18','sys18'),(141,'total18','total18'),(142,'user19','user19'),(143,'sys19','sys19'),(144,'total19','total19'),(145,'user20','user20'),(146,'sys20','sys20'),(147,'total20','total20'),(148,'user21','user21'),(149,'sys21','sys21'),(150,'total21','total21'),(151,'user22','user22'),(152,'sys22','sys22'),(153,'total22','total22'),(154,'user23','user23'),(155,'sys23','sys23'),(156,'total23','total23'),(157,'user24','user24'),(158,'sys24','sys24'),(159,'total24','total24'),(160,'user25','user25'),(161,'sys25','sys25'),(162,'total25','total25'),(163,'user26','user26'),(164,'sys26','sys26'),(165,'total26','total26'),(166,'user27','user27'),(167,'sys27','sys27'),(168,'total27','total27'),(169,'user28','user28'),(170,'sys28','sys28'),(171,'total28','total28'),(172,'user29','user29'),(173,'sys29','sys29'),(174,'total29','total29'),(175,'user30','user30'),(176,'sys30','sys30'),(177,'total30','total30'),(178,'user31','user31'),(179,'sys31','sys31'),(180,'total31','total31'),(181,'user32','user32'),(182,'sys32','sys32'),(183,'total32','total32'),(184,'user33','user33'),(185,'sys33','sys33'),(186,'total33','total33'),(187,'user34','user34'),(188,'sys34','sys34'),(189,'total34','total34'),(190,'user35','user35'),(191,'sys35','sys35'),(192,'total35','total35'),(193,'user36','user36'),(194,'sys36','sys36'),(195,'total36','total36'),(196,'user37','user37'),(197,'sys37','sys37'),(198,'total37','total37'),(199,'user38','user38'),(200,'sys38','sys38'),(201,'total38','total38'),(202,'user39','user39'),(203,'sys39','sys39'),(204,'total39','total39'),(205,'user40','user40'),(206,'sys40','sys40'),(207,'total40','total40'),(208,'pagesize2','pagesize2'),(209,'dskreads2','dskreads2'),(210,'pagereads2','pagereads2'),(211,'buffreads2','buffreads2'),(212,'rcachepc2','rcachepc2'),(213,'dskwrits2','dskwrits2'),(214,'pagwrits2','pagwrits2'),(215,'bufwrits2','bufwrits2'),(216,'wcachepc2','wcachepc2'),(217,'bufwrits_sinceckpt2','bufwrits_sinceckpt2'),(218,'bufwaits2','bufwaits2'),(219,'ovbuff2','ovbuff2'),(220,'flushes2','flushes2'),(221,'fgwrits2','fgwrits2'),(222,'lruwrites2','lruwrites2'),(223,'avlru2','avlru2'),(224,'chunkwrites2','chunkwrites2'),(225,'totalmemory2','totalmemory2'),(226,'id2','id2'),(227,'size2','size2'),(228,'buffers2','buffers2'),(229,'pagesize4','pagesize4'),(230,'dskreads4','dskreads4'),(231,'pagereads4','pagereads4'),(232,'buffreads4','buffreads4'),(233,'rcachepc4','rcachepc4'),(234,'dskwrits4','dskwrits4'),(235,'pagwrits4','pagwrits4'),(236,'bufwrits4','bufwrits4'),(237,'wcachepc4','wcachepc4'),(238,'bufwrits_sinceckpt4','bufwrits_sinceckpt4'),(239,'bufwaits4','bufwaits4'),(240,'ovbuff4','ovbuff4'),(241,'flushes4','flushes4'),(242,'fgwrits4','fgwrits4'),(243,'lruwrites4','lruwrites4'),(244,'avlru4','avlru4'),(245,'chunkwrites4','chunkwrites4'),(246,'totalmemory4','totalmemory4'),(247,'id4','id4'),(248,'size4','size4'),(249,'buffers4','buffers4'),(250,'pagesize8','pagesize8'),(251,'dskreads8','dskreads8'),(252,'pagereads8','pagereads8'),(253,'buffreads8','buffreads8'),(254,'rcachepc8','rcachepc8'),(255,'dskwrits8','dskwrits8'),(256,'pagwrits8','pagwrits8'),(257,'bufwrits8','bufwrits8'),(258,'wcachepc8','wcachepc8'),(259,'bufwrits_sinceckpt8','bufwrits_sinceckpt8'),(260,'bufwaits8','bufwaits8'),(261,'ovbuff8','ovbuff8'),(262,'flushes8','flushes8'),(263,'fgwrits8','fgwrits8'),(264,'lruwrites8','lruwrites8'),(265,'avlru8','avlru8'),(266,'chunkwrites8','chunkwrites8'),(267,'totalmemory8','totalmemory8'),(268,'id8','id8'),(269,'size8','size8'),(270,'buffers8','buffers8'),(271,'pagesize16','pagesize16'),(272,'dskreads16','dskreads16'),(273,'pagereads16','pagereads16'),(274,'buffreads16','buffreads16'),(275,'rcachepc16','rcachepc16'),(276,'dskwrits16','dskwrits16'),(277,'pagwrits16','pagwrits16'),(278,'bufwrits16','bufwrits16'),(279,'wcachepc16','wcachepc16'),(280,'bufwrits_sinceckpt16','bufwrits_sinceckpt16'),(281,'bufwaits16','bufwaits16'),(282,'ovbuff16','ovbuff16'),(283,'flushes16','flushes16'),(284,'fgwrits16','fgwrits16'),(285,'lruwrites16','lruwrites16'),(286,'avlru16','avlru16'),(287,'chunkwrites16','chunkwrites16'),(288,'totalmemory16','totalmemory16'),(289,'id16','id16'),(290,'size16','size16'),(291,'buffers16','buffers16');
/*!40000 ALTER TABLE `metric_header` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `row_sequence`
--

DROP TABLE IF EXISTS `row_sequence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `row_sequence` (
  `instance_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `counter` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`instance_id`,`date`),
  KEY `fk_row_sequence_instance1_idx` (`instance_id`),
  CONSTRAINT `fk_row_sequence_instance1` FOREIGN KEY (`instance_id`) REFERENCES `instance` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `row_sequence`
--

LOCK TABLES `row_sequence` WRITE;
/*!40000 ALTER TABLE `row_sequence` DISABLE KEYS */;
/*!40000 ALTER TABLE `row_sequence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `series`
--

DROP TABLE IF EXISTS `series`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `series` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `graph_id` int(11) NOT NULL,
  `series_types_name` varchar(10) COLLATE utf8_bin NOT NULL,
  `average` int(11) NOT NULL DEFAULT '1',
  `series_label` varchar(45) COLLATE utf8_bin NOT NULL,
  `series_sql` varchar(900) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`,`graph_id`,`series_types_name`),
  KEY `fk_series_graph1_idx` (`graph_id`),
  KEY `fk_series_series_types1_idx` (`series_types_name`),
  CONSTRAINT `fk_series_graph1` FOREIGN KEY (`graph_id`) REFERENCES `graph` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_series_series_types1` FOREIGN KEY (`series_types_name`) REFERENCES `series_types` (`name`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `series`
--

LOCK TABLES `series` WRITE;
/*!40000 ALTER TABLE `series` DISABLE KEYS */;
INSERT INTO `series` VALUES (13,1,'difference',1,'disk read','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"dskreads\"'),(14,1,'difference',1,'disk writes','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"dskwrits\"'),(15,2,'straight',5,'Percent Read Cache Hits','call  metric_delta_percent ( ?, \"bufreads\", \"dskreads\", \"metric_data\");'),(16,2,'straight',5,'Percent Writes to Memory','call  metric_delta_percent ( ?, \"bufwrits\", \"dskwrits\", \"metric_data\");'),(18,3,'time diff',1,'System CPU','select  metric_date, (data *100) as data from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"syscpu\"'),(19,3,'time diff',1,'User CPU','select metric_date, (data * 100) as data from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"usercpu\"'),(20,4,'difference',1,'Sequential Scans','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"seqscans\" '),(21,5,'difference',1,'Check Points','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"numckpts\" '),(22,6,'difference',1,'Commits','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"commit\" '),(23,6,'difference',1,'Roll backs','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"rollbk\" '),(24,7,'straight',1,'Dead Locks','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"deadlks\" '),(25,8,'straight',1,'Sessions','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"sessions\" '),(26,9,'straight',1,'Locks','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"activelocks\" '),(27,10,'straight',1,'Logical Logs','select d1.metric_date, (d1.data / d2.data * 100) as data from metric_header h1, metric_data d1, metric_header h2, metric_data d2 where h1.id = d1.metric_header_id and date(d1.metric_date) = ? and h1.metric_name = \"lltotalused\" and  h2.id = d2.metric_header_id and d2.metric_date = d1.metric_date and h2.metric_name = \"lltotalsize\"'),(28,10,'straight',1,'Physical Logs','select d1.metric_date, (d1.data / d2.data * 100) as data from metric_header h1, metric_data d1, metric_header h2, metric_data d2 where h1.id = d1.metric_header_id and date(d1.metric_date) = ? and h1.metric_name = \"pphyused\" and  h2.id = d2.metric_header_id and d2.metric_date = d1.metric_date and h2.metric_name = \"pphysize\"'),(32,12,'difference',1,'Connections','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"netaccept\" '),(33,12,'difference',1,'Rejections','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"netreject\" '),(34,13,'difference',1,'Buffer Waits','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"bufwaits\" '),(36,14,'straight',1,'Blocks Free','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"blkfree\" '),(37,14,'straight',1,'Blocks Used','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"blkused\" '),(38,15,'straight',1,'Log Buffer','select d1.metric_date, (d1.data / d2.data * 100) as data from metric_header h1, metric_data d1, metric_header h2, metric_data d2 where h1.id = d1.metric_header_id and date(d1.metric_date) = ? and h1.metric_name = \"lpagesio\" and  h2.id = d2.metric_header_id and d2.metric_date = d1.metric_date and h2.metric_name = \"lbufsize\"'),(39,15,'straight',1,'Physical Buffer','select d1.metric_date, (d1.data / d2.data * 100) as data from metric_header h1, metric_data d1, metric_header h2, metric_data d2 where h1.id = d1.metric_header_id and date(d1.metric_date) = ? and h1.metric_name = \"ppagesio\" and  h2.id = d2.metric_header_id and d2.metric_date = d1.metric_date and h2.metric_name = \"pbufsize\"'),(40,16,'difference',1,'User','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = ? '),(45,17,'straight',1,'Net Read','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"netread\" '),(46,17,'straight',1,'Net Write','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"netwrite\" '),(47,18,'difference',1,'Read Ahead Wastage','select h1.metric_name, h1.label, d1.metric_date, d1.data - sum(d2.data) as data, d1.metric_header_id, d1.instance_id, d1.seq_no from metric_header h1, metric_data d1, metric_header h2, metric_data d2 where h1.id = d1.metric_header_id and date(d1.metric_date) = ? and h1.metric_name = \"RApgsused\" and h2.id = d2.metric_header_id and d1.metric_date = d2.metric_date and h2.metric_name in (\"ixdaRA\", \"idxRA\", \"daRA\") group by h1.metric_name, h1.label, d1.metric_date, d1.data , d1.metric_header_id, d1.instance_id, d1.seq_no;'),(48,11,'straight',1,'Waiting Threads','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"threadwai\" '),(49,11,'straight',1,'Sleeping Threads','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"threadsle\" '),(50,11,'straight',1,'Ready Threads','select * from metric_header h, metric_data d1 where h.id = d1.metric_header_id and date(d1.metric_date) = ? and h.metric_name = \"threadrea\" ');
/*!40000 ALTER TABLE `series` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `series_set`
--

DROP TABLE IF EXISTS `series_set`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `series_set` (
  `series_id` int(11) NOT NULL,
  `sql` varchar(500) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`series_id`),
  CONSTRAINT `fk_series` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `series_set`
--

LOCK TABLES `series_set` WRITE;
/*!40000 ALTER TABLE `series_set` DISABLE KEYS */;
INSERT INTO `series_set` VALUES (40,'select metric_name, label from metric_header where REGEXP_LIKE (metric_name, \'^user[[:digit:]]*$\');');
/*!40000 ALTER TABLE `series_set` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `series_types`
--

DROP TABLE IF EXISTS `series_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `series_types` (
  `name` varchar(10) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `series_types`
--

LOCK TABLES `series_types` WRITE;
/*!40000 ALTER TABLE `series_types` DISABLE KEYS */;
INSERT INTO `series_types` VALUES ('difference'),('straight'),('time diff');
/*!40000 ALTER TABLE `series_types` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-12-16  0:17:58
