-- MySQL dump 10.13  Distrib 5.1.54, for debian-linux-gnu (i686)
--
-- Host: localhost    Database: auth_billing
-- ------------------------------------------------------
-- Server version	5.1.54-1ubuntu4

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `bundles`
--

DROP TABLE IF EXISTS `bundles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bundles` (
  `guid` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  UNIQUE KEY `bundles_by_guid` (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bundles`
--

LOCK TABLES `bundles` WRITE;
/*!40000 ALTER TABLE `bundles` DISABLE KEYS */;
INSERT INTO `bundles` VALUES ('4eaa9080-0909-012f-5f8c-704da2db2f5d-BUN','ezlandlordforms',NULL,'2011-12-15 10:42:28','2011-12-15 10:42:28'),('e3d9b6f0-0908-012f-5f8a-704da2db2f5d-BUN','one_free_rm_per_month',NULL,'2011-12-15 10:39:29','2011-12-15 10:39:29'),('e40b6010-0908-012f-5f8a-704da2db2f5d-BUN','ten_percent_off_all',NULL,'2011-12-15 10:39:29','2011-12-15 10:39:29');
/*!40000 ALTER TABLE `bundles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bundles_users`
--

DROP TABLE IF EXISTS `bundles_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bundles_users` (
  `bundle_id` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  UNIQUE KEY `users_bundles_index` (`user_id`,`bundle_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bundles_users`
--

LOCK TABLES `bundles_users` WRITE;
/*!40000 ALTER TABLE `bundles_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `bundles_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `charge_types`
--

DROP TABLE IF EXISTS `charge_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `charge_types` (
  `guid` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `price` decimal(12,2) NOT NULL,
  `description` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recurring` tinyint(1) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `category` varchar(20) DEFAULT NULL,
  UNIQUE KEY `charge_types_by_guid` (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `charge_types`
--

LOCK TABLES `charge_types` WRITE;
/*!40000 ALTER TABLE `charge_types` DISABLE KEYS */;
INSERT INTO `charge_types` VALUES ('4584cf00-0909-012f-5f8b-704da2db2f5d-BCT','ezlf_small','7.99','Ezlandlord Forms (Forms 5): Sync up to 5 units','2011-12-15 10:42:13','2011-12-15 10:42:28',1,1,NULL),('45932c60-0909-012f-5f8b-704da2db2f5d-BCT','ezlf_medium','19.99','Ezlandlord Forms (Forms 25): Sync up to 25 units','2011-12-15 10:42:13','2011-12-15 10:42:28',1,1,NULL),('4e242480-0909-012f-5f8c-704da2db2f5d-BCT','tenant_screening_plus_setup','75.00','One-time setup fee for Tenant Screening Plus.','2011-12-15 10:42:27','2011-12-15 10:42:27',0,1,NULL),('4e31ce60-0909-012f-5f8c-704da2db2f5d-BCT','tenant_screening_report','14.95','Charge for 1 Tenant Screening report.','2011-12-15 10:42:27','2011-12-15 10:42:27',0,1,NULL),('4e466540-0909-012f-5f8c-704da2db2f5d-BCT','rent_processing_unit','5.00','Monthly charge for accepting rent for a unit.','2011-12-15 10:42:27','2011-12-15 10:42:27',1,1,NULL),('4e6dbb20-0909-012f-5f8c-704da2db2f5d-BCT','ezlf_unlimited','49.99','Ezlandlord Forms (Forms Unlimited): Sync up to an unlimited number of units','2011-12-15 10:42:28','2011-12-15 10:42:28',1,1,NULL),('4e7aa1f0-0909-012f-5f8c-704da2db2f5d-BCT','tenant_screening_regular','17.99','Tenant Screening Report','2011-12-15 10:42:28','2011-12-15 10:42:28',0,1,NULL),('e20558f0-0908-012f-5f8a-704da2db2f5d-BCT','rentomatic_small','9.95','Rentomatic 1-5 Units','2011-12-15 10:39:26','2011-12-15 10:39:26',1,1,'rentomatic_monthly'),('e21556c0-0908-012f-5f8a-704da2db2f5d-BCT','rentomatic_medium','24.95','Rentomatic 6-25 Units','2011-12-15 10:39:26','2011-12-15 10:39:26',1,1,'rentomatic_monthly'),('e21e4c20-0908-012f-5f8a-704da2db2f5d-BCT','rentomatic_large','59.95','Rentomatic Unlimited','2011-12-15 10:39:26','2011-12-15 10:39:26',1,1,'rentomatic_monthly'),('e3c8a910-0908-012f-5f8a-704da2db2f5d-BCT','rent_management_subscription','5.00','Online Rent Payment','2011-12-15 10:39:29','2011-12-15 10:39:29',1,1,NULL),('e45a1d50-0908-012f-5f8a-704da2db2f5d-BCT','foreclosure','40.00','Foreclosure Finder','2011-12-15 10:39:30','2011-12-15 10:39:30',1,1,NULL);
/*!40000 ALTER TABLE `charge_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `credits`
--

DROP TABLE IF EXISTS `credits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `credits` (
  `guid` varchar(255) NOT NULL,
  `invoice_id` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  UNIQUE KEY `credits_by_guid` (`guid`),
  KEY `credits_by_invoice` (`invoice_id`(10))
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `credits`
--

LOCK TABLES `credits` WRITE;
/*!40000 ALTER TABLE `credits` DISABLE KEYS */;
/*!40000 ALTER TABLE `credits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `discounts`
--

DROP TABLE IF EXISTS `discounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `discounts` (
  `guid` varchar(255) NOT NULL,
  `bundle_id` varchar(255) NOT NULL,
  `price` decimal(12,2) NOT NULL,
  `duration` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `charge_type_id` varchar(255) NOT NULL,
  `reset_period` int(11) DEFAULT NULL,
  UNIQUE KEY `discounts_by_guid` (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `discounts`
--

LOCK TABLES `discounts` WRITE;
/*!40000 ALTER TABLE `discounts` DISABLE KEYS */;
INSERT INTO `discounts` VALUES ('4eb4fa70-0909-012f-5f8c-704da2db2f5d-BDI','4eaa9080-0909-012f-5f8c-704da2db2f5d-BUN','7.95',NULL,'2011-12-15 10:42:28','2011-12-15 10:42:28','e20558f0-0908-012f-5f8a-704da2db2f5d-BCT',NULL),('4ebe14c0-0909-012f-5f8c-704da2db2f5d-BDI','4eaa9080-0909-012f-5f8c-704da2db2f5d-BUN','20.95',NULL,'2011-12-15 10:42:28','2011-12-15 10:42:28','e21556c0-0908-012f-5f8a-704da2db2f5d-BCT',NULL),('4ec47410-0909-012f-5f8c-704da2db2f5d-BDI','4eaa9080-0909-012f-5f8c-704da2db2f5d-BUN','49.95',NULL,'2011-12-15 10:42:28','2011-12-15 10:42:28','e21e4c20-0908-012f-5f8a-704da2db2f5d-BCT',NULL),('e3ed9170-0908-012f-5f8a-704da2db2f5d-BDI','e3d9b6f0-0908-012f-5f8a-704da2db2f5d-BUN','0.00',1,'2011-12-15 10:39:29','2011-12-15 10:39:29','e3c8a910-0908-012f-5f8a-704da2db2f5d-BCT',1),('e41ffef0-0908-012f-5f8a-704da2db2f5d-BDI','e40b6010-0908-012f-5f8a-704da2db2f5d-BUN','8.96',NULL,'2011-12-15 10:39:29','2011-12-15 10:39:29','e20558f0-0908-012f-5f8a-704da2db2f5d-BCT',NULL),('e42c2af0-0908-012f-5f8a-704da2db2f5d-BDI','e40b6010-0908-012f-5f8a-704da2db2f5d-BUN','22.46',NULL,'2011-12-15 10:39:29','2011-12-15 10:39:29','e21556c0-0908-012f-5f8a-704da2db2f5d-BCT',NULL),('e433c320-0908-012f-5f8a-704da2db2f5d-BDI','e40b6010-0908-012f-5f8a-704da2db2f5d-BUN','53.96',NULL,'2011-12-15 10:39:29','2011-12-15 10:39:29','e21e4c20-0908-012f-5f8a-704da2db2f5d-BCT',NULL),('e43a20f0-0908-012f-5f8a-704da2db2f5d-BDI','e40b6010-0908-012f-5f8a-704da2db2f5d-BUN','4.50',NULL,'2011-12-15 10:39:29','2011-12-15 10:39:29','e3c8a910-0908-012f-5f8a-704da2db2f5d-BCT',NULL);
/*!40000 ALTER TABLE `discounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gateway_responses`
--

DROP TABLE IF EXISTS `gateway_responses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gateway_responses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gateway_name` varchar(255) DEFAULT NULL,
  `authorization` varchar(255) DEFAULT NULL,
  `success` tinyint(1) DEFAULT '0',
  `cvv_message` varchar(255) DEFAULT NULL,
  `cvv_code` varchar(255) DEFAULT NULL,
  `fraud_review` varchar(255) DEFAULT NULL,
  `message` varchar(255) DEFAULT NULL,
  `params` text,
  `avs_message` varchar(255) DEFAULT NULL,
  `avs_code` varchar(255) DEFAULT NULL,
  `avs_street_match` varchar(255) DEFAULT NULL,
  `avs_postal_match` varchar(255) DEFAULT NULL,
  `test` tinyint(1) DEFAULT '0',
  `request_type` varchar(255) DEFAULT NULL,
  `associated_id` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gateway_responses`
--

LOCK TABLES `gateway_responses` WRITE;
/*!40000 ALTER TABLE `gateway_responses` DISABLE KEYS */;
/*!40000 ALTER TABLE `gateway_responses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoice_transitions`
--

DROP TABLE IF EXISTS `invoice_transitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoice_transitions` (
  `guid` varchar(255) NOT NULL,
  `invoice_id` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  UNIQUE KEY `invoice_transitions_by_guid` (`guid`),
  KEY `invoice_transitions_by_invoice` (`invoice_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoice_transitions`
--

LOCK TABLES `invoice_transitions` WRITE;
/*!40000 ALTER TABLE `invoice_transitions` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoice_transitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoices` (
  `guid` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `monthly` tinyint(1) NOT NULL DEFAULT '0',
  `total` decimal(12,2) NOT NULL,
  `balance` decimal(12,2) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'fresh',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `frozen_html` text,
  `frozen_email` varchar(255) DEFAULT NULL,
  KEY `invoices_by_user` (`user_id`(10))
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `line_items`
--

DROP TABLE IF EXISTS `line_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `line_items` (
  `guid` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `service_id` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `group_name` varchar(255) DEFAULT NULL,
  `amount` decimal(12,2) NOT NULL,
  `sticker_price` decimal(12,2) DEFAULT NULL,
  `occurred_at` datetime DEFAULT NULL,
  `monthly_invoice_id` varchar(255) DEFAULT NULL,
  `midmonth_invoice_id` varchar(255) DEFAULT NULL,
  `monthly_line_number` int(11) DEFAULT NULL,
  `midmonth_line_number` int(11) DEFAULT NULL,
  `source_type` varchar(255) DEFAULT NULL,
  `source_id` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `charge_type_id` varchar(255) DEFAULT NULL,
  UNIQUE KEY `line_items_by_guid` (`guid`),
  KEY `line_items_by_user` (`user_id`(10)),
  KEY `line_items_by_midmonth` (`midmonth_invoice_id`(10)),
  KEY `line_items_by_monthly` (`monthly_invoice_id`(10)),
  KEY `line_items_by_source` (`source_type`(5),`source_id`(10)),
  KEY `index_line_items_on_charge_type_id` (`charge_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `line_items`
--

LOCK TABLES `line_items` WRITE;
/*!40000 ALTER TABLE `line_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `line_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `one_time_charges`
--

DROP TABLE IF EXISTS `one_time_charges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `one_time_charges` (
  `guid` varchar(255) NOT NULL,
  `charge_type_id` varchar(255) NOT NULL,
  `foreign_id` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  UNIQUE KEY `one_time_charges_by_guid` (`guid`),
  KEY `one_time_charges_by_foreign` (`charge_type_id`(10),`foreign_id`(10))
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `one_time_charges`
--

LOCK TABLES `one_time_charges` WRITE;
/*!40000 ALTER TABLE `one_time_charges` DISABLE KEYS */;
/*!40000 ALTER TABLE `one_time_charges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('1'),('10'),('11'),('12'),('13'),('14'),('15'),('16'),('17'),('18'),('19'),('2'),('20'),('20090825152039'),('20091002202340'),('20091105163516'),('20091123220322'),('20091125204046'),('20100105192101'),('20100106144950'),('20100118000015'),('20100219202504'),('20100223224430'),('20100401232157'),('20100419210739'),('21'),('22'),('23'),('24'),('25'),('26'),('27'),('28'),('29'),('3'),('30'),('31'),('32'),('33'),('34'),('35'),('36'),('37'),('38'),('39'),('4'),('40'),('41'),('42'),('43'),('44'),('45'),('46'),('47'),('48'),('49'),('5'),('50'),('51'),('52'),('53'),('54'),('55'),('56'),('6'),('7'),('8'),('9');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `services`
--

DROP TABLE IF EXISTS `services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `services` (
  `short_name` varchar(255) NOT NULL,
  `long_name` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  UNIQUE KEY `services_by_short_name` (`short_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `services`
--

LOCK TABLES `services` WRITE;
/*!40000 ALTER TABLE `services` DISABLE KEYS */;
/*!40000 ALTER TABLE `services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscriptions`
--

DROP TABLE IF EXISTS `subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscriptions` (
  `guid` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `charge_type_id` varchar(255) NOT NULL,
  `service_id` varchar(255) NOT NULL,
  `joined_at` datetime NOT NULL DEFAULT '2011-12-15 10:39:08',
  `terminated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `trial_days` int(11) DEFAULT '0',
  `foreign_id` varchar(255) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `group_name` varchar(255) DEFAULT NULL,
  UNIQUE KEY `subscriptions_by_guid` (`guid`),
  KEY `subscriptions_by_user` (`user_id`(10))
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscriptions`
--

LOCK TABLES `subscriptions` WRITE;
/*!40000 ALTER TABLE `subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `guid` varchar(255) NOT NULL,
  `anniversary` smallint(6) DEFAULT NULL,
  `max_debt` decimal(12,2) NOT NULL,
  `balance` decimal(12,2) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `next_anniversary_on` date DEFAULT NULL,
  `prevent_payment_requests` tinyint(1) NOT NULL DEFAULT '0',
  UNIQUE KEY `users_by_guid` (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('79b953a0-0884-012f-5f89-704da2db2f5d-USR',NULL,'25.00','0.00','2011-12-15 10:43:52','2011-12-15 10:43:52',1,NULL,0),('a7fdd340-0911-012f-5f89-704da2db2f5d-USR',NULL,'25.00','0.00','2011-12-15 11:42:15','2011-12-15 11:42:15',1,NULL,0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-12-15 12:18:59
