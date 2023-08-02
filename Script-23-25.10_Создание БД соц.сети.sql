DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;
USE vk;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
    firstname VARCHAR(100),
    lastname VARCHAR(100) COMMENT 'Фамилия', -- COMMENT на случай, если имя неочевидное
    email VARCHAR(100) UNIQUE,
    password_hash varchar(100),
    phone BIGINT,
    is_deleted bit default b'0',
    -- INDEX users_phone_idx(phone), -- помним: как выбирать индексы
    INDEX users_firstname_lastname_idx(firstname, lastname)
);

DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
	user_id SERIAL PRIMARY KEY,
    gender CHAR(1),
    birthday DATE,
	photo_id BIGINT UNSIGNED,
    created_at DATETIME DEFAULT NOW(),
    hometown VARCHAR(100)
    -- , FOREIGN KEY (photo_id) REFERENCES media(id) -- пока рано, т.к. таблицы media еще нет
);

-- NO ACTION
-- CASCADE 
-- RESTRICT
-- SET NULL
-- SET DEFAULT


ALTER TABLE `profiles` ADD CONSTRAINT fk_user_id
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE CASCADE;

DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(), -- можно будет даже не упоминать это поле при вставке

    FOREIGN KEY (from_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (to_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
	-- id SERIAL PRIMARY KEY, -- изменили на составной ключ (initiator_user_id, target_user_id)
	initiator_user_id BIGINT UNSIGNED NOT NULL,
    target_user_id BIGINT UNSIGNED NOT NULL,
    -- `status` TINYINT UNSIGNED,
    `status` ENUM('requested', 'approved', 'declined', 'unfriended'),
    -- `status` TINYINT UNSIGNED, -- в этом случае в коде хранили бы цифирный enum (0, 1, 2, 3...)
	requested_at DATETIME DEFAULT NOW(),
	updated_at DATETIME on update now(),
	
    PRIMARY KEY (initiator_user_id, target_user_id),
    FOREIGN KEY (initiator_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (target_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS communities;
CREATE TABLE communities(
	id SERIAL PRIMARY KEY,
	name VARCHAR(150),
	admin_user_id BIGINT UNSIGNED,

	INDEX communities_name_idx(name),
	FOREIGN KEY (admin_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

DROP TABLE IF EXISTS users_communities;
CREATE TABLE users_communities(
	user_id BIGINT UNSIGNED NOT NULL,
	community_id BIGINT UNSIGNED NOT NULL,
  
	PRIMARY KEY (user_id, community_id), -- чтобы не было 2 записей о пользователе и сообществе
    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (community_id) REFERENCES communities(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

    -- записей мало, поэтому индекс будет лишним (замедлит работу)!
);

DROP TABLE IF EXISTS media;
CREATE TABLE media(
	id SERIAL PRIMARY KEY,
    media_type_id BIGINT UNSIGNED,
    user_id BIGINT UNSIGNED NOT NULL,
  	body text,
    filename VARCHAR(255),
    `size` INT,
	metadata JSON,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (media_type_id) REFERENCES media_types(id) ON UPDATE CASCADE ON DELETE SET NULL
);

DROP TABLE IF EXISTS likes;
CREATE TABLE likes(
	id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    media_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),

    -- PRIMARY KEY (user_id, media_id) – можно было и так вместо id в качестве PK
  	-- слишком увлекаться индексами тоже опасно, рациональнее их добавлять по мере необходимости (напр., провисают по времени какие-то запросы)  

/* намеренно забыли, чтобы позднее увидеть их отсутствие в ER-диаграмме*/
    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (media_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE

);

DROP TABLE IF EXISTS `photo_albums`;
CREATE TABLE `photo_albums` (
	`id` SERIAL,
	`name` varchar(255) DEFAULT NULL,
    `user_id` BIGINT UNSIGNED DEFAULT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  	PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `photos`;
CREATE TABLE `photos` (
	id SERIAL PRIMARY KEY,
	`album_id` BIGINT UNSIGNED NOT NULL,
	`media_id` BIGINT UNSIGNED NOT NULL,

	FOREIGN KEY (album_id) REFERENCES photo_albums(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (media_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE `profiles` ADD CONSTRAINT fk_photo_id
    FOREIGN KEY (photo_id) REFERENCES photos(id)
    ON UPDATE CASCADE ON DELETE SET NULL;
   
DROP TABLE IF EXISTS relations; #Для статусов, более сильных, чем дружба
CREATE TABLE relations(
	first_user_id BIGINT UNSIGNED NOT NULL,
	second_user_id BIGINT UNSIGNED NOT NULL,
	status ENUM('dating', 'married'),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
	
	PRIMARY KEY (first_user_id, second_user_id),
	FOREIGN KEY (first_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (second_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

# 1 x M
DROP TABLE IF EXISTS user_links; #Для хранения полезных ссылок
CREATE TABLE user_links(
	id SERIAL,
	user_id BIGINT UNSIGNED NOT NULL,
	description VARCHAR(255),
	link TEXT,
	created_at DATETIME DEFAULT NOW(),
	
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

# 1 x M
DROP TABLE IF EXISTS countries;
CREATE TABLE countries(
	id SERIAL,
	country_name ENUM('Russia', 'USA', 'China', 'Italy'), #Полный перечень стран мира
		
	INDEX (country_name)
);

DROP TABLE IF EXISTS trips; #Какие страны посещал пользователь
CREATE TABLE trips(
	user_id BIGINT UNSIGNED NOT NULL,
	country_name BIGINT UNSIGNED NOT NULL,
	
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (country_name) REFERENCES countries(id) ON UPDATE CASCADE ON DELETE CASCADE
);

# M x M
DROP TABLE IF EXISTS families; #Для групп по родственному признаку
CREATE TABLE families(
	id SERIAL,
	family_name VARCHAR(200),
	head_of_family_id BIGINT UNSIGNED NOT NULL,
	
	INDEX (family_name),
	FOREIGN KEY (head_of_family_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS users_families; #Подразумевается, что пользователь может состоять в разных семьях - по линии своих родителей, по линии супруга и т.п.
CREATE TABLE users_families(
	user_id BIGINT UNSIGNED NOT NULL,
	family_id BIGINT UNSIGNED NOT NULL,
	
	PRIMARY KEY (user_id, family_id),
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (family_id) REFERENCES families(id) ON UPDATE CASCADE ON DELETE CASCADE
);


