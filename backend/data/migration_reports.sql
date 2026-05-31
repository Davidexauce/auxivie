-- Signalements utilisateurs (app mobile — Signaler)
-- Colonne userId = auteur du signalement (reporterId côté API JSON)
CREATE TABLE IF NOT EXISTS `reports` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `userId` INT NOT NULL,
  `reportedUserId` INT NULL,
  `reservationId` INT NULL,
  `type` VARCHAR(50) NOT NULL,
  `message` TEXT NOT NULL,
  `status` VARCHAR(20) DEFAULT 'open',
  `createdAt` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `resolvedAt` DATETIME NULL,
  INDEX `idx_userId` (`userId`),
  INDEX `idx_reportedUserId` (`reportedUserId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
