CREATE TABLE IF NOT EXISTS `gangs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `inventory` longtext DEFAULT NULL,
  `leadership_rank` int(11) NOT NULL DEFAULT 3,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

INSERT INTO `gangs` (`id`, `name`, `label`, `inventory`, `leadership_rank`) VALUES
	(1, 'woo', 'Woo', '{"dcash":0,"items":{"medikit":0,"meth_pooch":0,"bandage":0,"rolex":0,"diamond":0,"opium_pooch":0,"opium":0,"coke":0,"coke_pooch":0,"jewels":0,"meth":0},"cash":0}', 4),
	(2, 'otf', 'OTF', '{"dcash":0,"items":{"medikit":0,"meth_pooch":0,"bandage":0,"rolex":0,"diamond":0,"opium_pooch":0,"opium":0,"coke":0,"coke_pooch":0,"jewels":0,"meth":0},"cash":0}', 4),
	(3, 'gd', 'GD', '{"dcash":0,"items":{"medikit":0,"meth_pooch":0,"bandage":0,"rolex":0,"diamond":0,"opium_pooch":0,"opium":0,"coke":0,"coke_pooch":0,"jewels":0,"meth":0},"cash":0}', 4);

CREATE TABLE IF NOT EXISTS `gang_ranks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `gang_name` varchar(255) DEFAULT NULL,
  `ranking` int(11) DEFAULT NULL,
  `vehicles` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

INSERT INTO `gang_ranks` (`id`, `name`, `label`, `gang_name`, `ranking`, `vehicles`) VALUES
	(1, 'recruit', 'Recruit', 'woo', 0, NULL),
	(2, 'member', 'Member', 'woo', 1, NULL),
	(3, 'shooter', 'Shooter', 'woo', 2, NULL),
	(4, 'topshooter', 'Top Shooter', 'woo', 3, NULL),
	(5, 'owner', 'Owner', 'otf', 4, NULL),
	(21, 'recruit', 'Recruit', 'otf', 0, NULL),
	(22, 'member', 'Member', 'otf', 1, NULL),
	(23, 'shooter', 'Shooter', 'otf', 2, NULL),
	(24, 'topshooter', 'Top Shooter', 'otf', 3, NULL),
	(25, 'owner', 'Owner', 'otf', 4, NULL),
	(31, 'recruit', 'Recruit', 'gd', 0, NULL),
	(32, 'member', 'Member', 'gd', 1, NULL),
	(33, 'shooter', 'Shooter', 'gd', 2, NULL),
	(34, 'topshooter', 'Top Shooter', 'gd', 3, NULL),
	(35, 'owner', 'Owner', 'gd', 4, NULL);