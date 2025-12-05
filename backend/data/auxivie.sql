BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "admins" (
	"id"	INTEGER,
	"email"	TEXT NOT NULL UNIQUE,
	"password"	TEXT NOT NULL,
	"name"	TEXT NOT NULL,
	"createdAt"	TEXT DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "availabilities" (
	"id"	INTEGER,
	"professionnelId"	INTEGER NOT NULL,
	"jourSemaine"	INTEGER NOT NULL,
	"heureDebut"	TEXT NOT NULL,
	"heureFin"	TEXT NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("professionnelId") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "disputes" (
	"id"	INTEGER,
	"reservationId"	INTEGER NOT NULL,
	"userId"	INTEGER NOT NULL,
	"title"	TEXT NOT NULL,
	"description"	TEXT NOT NULL,
	"status"	TEXT DEFAULT 'pending',
	"resolution"	TEXT,
	"createdAt"	TEXT DEFAULT CURRENT_TIMESTAMP,
	"resolvedAt"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("reservationId") REFERENCES "reservations"("id"),
	FOREIGN KEY("userId") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "documents" (
	"id"	INTEGER,
	"userId"	INTEGER NOT NULL,
	"type"	TEXT NOT NULL,
	"path"	TEXT NOT NULL,
	"status"	TEXT DEFAULT 'pending',
	"createdAt"	TEXT DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("userId") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "messages" (
	"id"	INTEGER,
	"senderId"	INTEGER NOT NULL,
	"receiverId"	INTEGER NOT NULL,
	"content"	TEXT NOT NULL,
	"timestamp"	TEXT NOT NULL,
	"isRead"	INTEGER DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("receiverId") REFERENCES "users"("id"),
	FOREIGN KEY("senderId") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "payments" (
	"id"	INTEGER,
	"reservationId"	INTEGER NOT NULL,
	"amount"	REAL NOT NULL,
	"status"	TEXT DEFAULT 'pending',
	"method"	TEXT,
	"transactionId"	TEXT,
	"createdAt"	TEXT DEFAULT CURRENT_TIMESTAMP,
	"userId"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("reservationId") REFERENCES "reservations"("id")
);
CREATE TABLE IF NOT EXISTS "platform_settings" (
	"id"	INTEGER,
	"key"	TEXT NOT NULL UNIQUE,
	"value"	TEXT NOT NULL,
	"updatedAt"	TEXT DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "reservations" (
	"id"	INTEGER,
	"userId"	INTEGER NOT NULL,
	"professionnelId"	INTEGER NOT NULL,
	"date"	TEXT NOT NULL,
	"heure"	TEXT NOT NULL,
	"status"	TEXT NOT NULL DEFAULT 'pending',
	"createdAt"	TEXT DEFAULT CURRENT_TIMESTAMP,
	"dateFin"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("professionnelId") REFERENCES "users"("id"),
	FOREIGN KEY("userId") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "reviews" (
	"id"	INTEGER,
	"reservationId"	INTEGER NOT NULL,
	"userId"	INTEGER NOT NULL,
	"professionalId"	INTEGER NOT NULL,
	"rating"	INTEGER NOT NULL,
	"comment"	TEXT,
	"createdAt"	TEXT DEFAULT CURRENT_TIMESTAMP,
	"userName"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("professionalId") REFERENCES "users"("id"),
	FOREIGN KEY("reservationId") REFERENCES "reservations"("id"),
	FOREIGN KEY("userId") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "user_badges" (
	"id"	INTEGER,
	"userId"	INTEGER NOT NULL,
	"badgeType"	TEXT NOT NULL,
	"badgeName"	TEXT NOT NULL,
	"badgeIcon"	TEXT,
	"description"	TEXT,
	"createdAt"	TEXT DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("userId") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "user_ratings" (
	"id"	INTEGER,
	"userId"	INTEGER NOT NULL,
	"averageRating"	REAL DEFAULT 0,
	"totalRatings"	INTEGER DEFAULT 0,
	"updatedAt"	TEXT DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id" AUTOINCREMENT),
	UNIQUE("userId"),
	FOREIGN KEY("userId") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "users" (
	"id"	INTEGER,
	"name"	TEXT NOT NULL,
	"firstName"	TEXT,
	"lastName"	TEXT,
	"dateOfBirth"	TEXT,
	"address"	TEXT,
	"email"	TEXT NOT NULL UNIQUE,
	"password"	TEXT NOT NULL,
	"phone"	TEXT,
	"categorie"	TEXT NOT NULL,
	"ville"	TEXT,
	"tarif"	REAL,
	"experience"	INTEGER,
	"photo"	TEXT,
	"userType"	TEXT NOT NULL,
	"suspended"	INTEGER DEFAULT 0,
	"createdAt"	TEXT DEFAULT CURRENT_TIMESTAMP,
	"updatedAt"	TEXT DEFAULT CURRENT_TIMESTAMP,
	"besoin"	TEXT,
	"preference"	TEXT,
	"mission"	TEXT,
	"particularite"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
);
INSERT INTO "admins" VALUES (3,'admin@auxivie.com','$2a$10$Ops1fDcX8lqeTJAG.UVkjeZ03PxWSWxd536U3SLxb9dGQxap2KY02','Admin','2025-11-27 19:26:14');
INSERT INTO "messages" VALUES (1,18,19,'Test message','2025-12-03 21:08:39',0);
INSERT INTO "messages" VALUES (2,20,18,'Bonjour','2025-12-03 21:10:03',0);
INSERT INTO "messages" VALUES (3,18,20,'Ca va','2025-12-03 21:18:56',0);
INSERT INTO "reservations" VALUES (2,20,18,'2025-12-17','15:00','pending','2025-12-03 21:09:50',NULL);
INSERT INTO "users" VALUES (8,'Administrateur',NULL,NULL,NULL,NULL,'admin@auxivie.com','$2b$10$.cojiJx7dLmdWfVGRBz//eCrWjzIASSr5IQpdpARyQioxSv2wfLBG',NULL,'Admin',NULL,NULL,NULL,NULL,'admin',0,'2025-12-01 19:08:19','2025-12-01 19:08:19',NULL,NULL,NULL,NULL);
INSERT INTO "users" VALUES (18,'DAVID Exauce',NULL,NULL,NULL,NULL,'lolo@gmail.com','$2b$10$cfyByARfTwZ2QmGGdHMgtuWFvTTppR/auWJZuj0HZjoLFDk00Hp.O','0776654332','Auxiliaire de vie','Melun',50.0,9,NULL,'professionnel',0,'2025-12-03 20:47:16','2025-12-03 20:47:16',NULL,NULL,NULL,NULL);
INSERT INTO "users" VALUES (19,'Test User',NULL,NULL,NULL,NULL,'test@test.com','$2b$10$Ac.nAdG7yXxtkvfsI908f./jgXmLHF4t3Iszfqck.iz/e94QNuTnq',NULL,'Famille',NULL,NULL,NULL,NULL,'famille',0,'2025-12-03 20:48:23','2025-12-03 20:48:23',NULL,NULL,NULL,NULL);
INSERT INTO "users" VALUES (20,'Valerie BOSS',NULL,NULL,NULL,NULL,'dodo@gmail.com','$2b$10$4y.DVs7COea/rcaUQHJzD.w8FnmRsYFVEZaUVgGkWta5Drp9P9wOm','0987654345','Famille',NULL,NULL,NULL,NULL,'famille',0,'2025-12-03 20:55:37','2025-12-03 20:55:37',NULL,NULL,NULL,NULL);
COMMIT;
