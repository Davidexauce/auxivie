SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

-- Table: admins
DROP TABLE IF EXISTS `admins`;
CREATE TABLE `admins` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `createdAt` VARCHAR(255) DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: availabilities
DROP TABLE IF EXISTS `availabilities`;
CREATE TABLE `availabilities` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `professionnelId` INT NOT NULL,
  `jourSemaine` INT NOT NULL,
  `heureDebut` VARCHAR(255) NOT NULL,
  `heureFin` VARCHAR(255) NOT NULL,
  FOREIGN KEY (`professionnelId`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: disputes
DROP TABLE IF EXISTS `disputes`;
CREATE TABLE `disputes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `reservationId` INT NOT NULL,
  `userId` INT NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `status` VARCHAR(255) DEFAULT 'pending',
  `resolution` TEXT,
  `createdAt` VARCHAR(255) DEFAULT CURRENT_TIMESTAMP,
  `resolvedAt` VARCHAR(255),
  FOREIGN KEY (`reservationId`) REFERENCES `reservations` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: documents
DROP TABLE IF EXISTS `documents`;
CREATE TABLE `documents` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `userId` INT NOT NULL,
  `type` VARCHAR(255) NOT NULL,
  `path` VARCHAR(255) NOT NULL,
  `status` VARCHAR(255) DEFAULT 'pending',
  `createdAt` VARCHAR(255) DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: messages
DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `senderId` INT NOT NULL,
  `receiverId` INT NOT NULL,
  `content` TEXT NOT NULL,
  `timestamp` VARCHAR(255) NOT NULL,
  `isRead` INT DEFAULT 0,
  FOREIGN KEY (`receiverId`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`senderId`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: payments
DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `reservationId` INT NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `status` VARCHAR(255) DEFAULT 'pending',
  `method` VARCHAR(255),
  `transactionId` VARCHAR(255),
  `createdAt` VARCHAR(255) DEFAULT CURRENT_TIMESTAMP,
  `userId` INT,
  FOREIGN KEY (`reservationId`) REFERENCES `reservations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: platform_settings
DROP TABLE IF EXISTS `platform_settings`;
CREATE TABLE `platform_settings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `key` VARCHAR(255) NOT NULL UNIQUE,
  `value` TEXT NOT NULL,
  `updatedAt` VARCHAR(255) DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: reservations
DROP TABLE IF EXISTS `reservations`;
CREATE TABLE `reservations` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `userId` INT NOT NULL,
  `professionnelId` INT NOT NULL,
  `date` VARCHAR(255) NOT NULL,
  `heure` VARCHAR(255) NOT NULL,
  `status` VARCHAR(255) NOT NULL DEFAULT 'pending',
  `createdAt` VARCHAR(255) DEFAULT CURRENT_TIMESTAMP,
  `dateFin` VARCHAR(255),
  FOREIGN KEY (`professionnelId`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: reviews
DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `reservationId` INT NOT NULL,
  `userId` INT NOT NULL,
  `professionalId` INT NOT NULL,
  `rating` INT NOT NULL,
  `comment` TEXT,
  `createdAt` VARCHAR(255) DEFAULT CURRENT_TIMESTAMP,
  `userName` VARCHAR(255),
  FOREIGN KEY (`professionalId`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`reservationId`) REFERENCES `reservations` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: user_badges
DROP TABLE IF EXISTS `user_badges`;
CREATE TABLE `user_badges` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `userId` INT NOT NULL,
  `badgeType` VARCHAR(255) NOT NULL,
  `badgeName` VARCHAR(255) NOT NULL,
  `badgeIcon` VARCHAR(255),
  `description` TEXT,
  `createdAt` VARCHAR(255) DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: user_ratings
DROP TABLE IF EXISTS `user_ratings`;
CREATE TABLE `user_ratings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `userId` INT NOT NULL UNIQUE,
  `averageRating` DECIMAL(10,2) DEFAULT 0,
  `totalRatings` INT DEFAULT 0,
  `updatedAt` VARCHAR(255) DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: users
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `firstName` VARCHAR(255),
  `lastName` VARCHAR(255),
  `dateOfBirth` VARCHAR(255),
  `address` TEXT,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(255),
  `categorie` VARCHAR(255) NOT NULL,
  `ville` VARCHAR(255),
  `tarif` DECIMAL(10,2),
  `experience` INT,
  `photo` VARCHAR(255),
  `userType` VARCHAR(255) NOT NULL,
  `suspended` INT DEFAULT 0,
  `createdAt` VARCHAR(255) DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` VARCHAR(255) DEFAULT CURRENT_TIMESTAMP,
  `besoin` TEXT,
  `preference` TEXT,
  `mission` TEXT,
  `particularite` TEXT,
  INDEX `idx_email` (`email`),
  INDEX `idx_userType` (`userType`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Données
INSERT INTO `admins` (`id`, `email`, `password`, `name`, `createdAt`) VALUES 
(3, 'admin@auxivie.com', '$2a$10$Ops1fDcX8lqeTJAG.UVkjeZ03PxWSWxd536U3SLxb9dGQxap2KY02', 'Admin', '2025-11-27 19:26:14');

INSERT INTO `messages` (`id`, `senderId`, `receiverId`, `content`, `timestamp`, `isRead`) VALUES 
(1, 18, 19, 'Test message', '2025-12-03 21:08:39', 0),
(2, 20, 18, 'Bonjour', '2025-12-03 21:10:03', 0),
(3, 18, 20, 'Ca va', '2025-12-03 21:18:56', 0);

INSERT INTO `reservations` (`id`, `userId`, `professionnelId`, `date`, `heure`, `status`, `createdAt`, `dateFin`) VALUES 
(2, 20, 18, '2025-12-17', '15:00', 'pending', '2025-12-03 21:09:50', NULL);

INSERT INTO `users` (`id`, `name`, `firstName`, `lastName`, `dateOfBirth`, `address`, `email`, `password`, `phone`, `categorie`, `ville`, `tarif`, `experience`, `photo`, `userType`, `suspended`, `createdAt`, `updatedAt`, `besoin`, `preference`, `mission`, `particularite`) VALUES 
(8, 'Administrateur', NULL, NULL, NULL, NULL, 'admin@auxivie.com', '$2b$10$.cojiJx7dLmdWfVGRBz//eCrWjzIASSr5IQpdpARyQioxSv2wfLBG', NULL, 'Admin', NULL, NULL, NULL, NULL, 'admin', 0, '2025-12-01 19:08:19', '2025-12-01 19:08:19', NULL, NULL, NULL, NULL),
(18, 'DAVID Exauce', NULL, NULL, NULL, NULL, 'lolo@gmail.com', '$2b$10$cfyByARfTwZ2QmGGdHMgtuWFvTTppR/auWJZuj0HZjoLFDk00Hp.O', '0776654332', 'Auxiliaire de vie', 'Melun', 50.00, 9, NULL, 'professionnel', 0, '2025-12-03 20:47:16', '2025-12-03 20:47:16', NULL, NULL, NULL, NULL),
(19, 'Test User', NULL, NULL, NULL, NULL, 'test@test.com', '$2b$10$Ac.nAdG7yXxtkvfsI908f./jgXmLHF4t3Iszfqck.iz/e94QNuTnq', NULL, 'Famille', NULL, NULL, NULL, NULL, 'famille', 0, '2025-12-03 20:48:23', '2025-12-03 20:48:23', NULL, NULL, NULL, NULL),
(20, 'Valerie BOSS', NULL, NULL, NULL, NULL, 'dodo@gmail.com', '$2b$10$4y.DVs7COea/rcaUQHJzD.w8FnmRsYFVEZaUVgGkWta5Drp9P9wOm', '0987654345', 'Famille', NULL, NULL, NULL, NULL, 'famille', 0, '2025-12-03 20:55:37', '2025-12-03 20:55:37', NULL, NULL, NULL, NULL);

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
