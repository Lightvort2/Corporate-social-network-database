# 1 x 1
DROP TABLE IF EXISTS relations; #Для статусов, более сильных, чем дружба
CREATE TABLE relations(
	first_user_id BIGINT UNSIGNED NOT NULL,
	second_user_id BIGINT UNSIGNED NOT NULL,
	status ENUM('dating', 'married'),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
	
	PRIMARY KEY (first_user_id, second_user_id),
	FOREIGN KEY (first_user_id) REFERENCES users(id),
	FOREIGN KEY (second_user_id) REFERENCES users(id),
	CHECK (first_user_id != second_user_id)
);

# 1 x M
DROP TABLE IF EXISTS user_links; #Для хранения полезных ссылок
CREATE TABLE user_links(
	id SERIAL,
	user_id BIGINT UNSIGNED NOT NULL,
	description VARCHAR(255),
	link TEXT,
	created_at DATETIME DEFAULT NOW(),
	
	FOREIGN KEY (user_id) REFERENCES users(id)
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
	
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (country_name) REFERENCES countries(id)
);

# M x M
DROP TABLE IF EXISTS families; #Для групп по родственному признаку
CREATE TABLE families(
	id SERIAL,
	family_name VARCHAR(200),
	head_of_family_id BIGINT UNSIGNED NOT NULL,
	
	INDEX (family_name),
	FOREIGN KEY (head_of_family_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS users_families; #Подразумевается, что пользователь может состоять в разных семьях - по линии своих родителей, по линии супруга и т.п.
CREATE TABLE users_families(
	user_id BIGINT UNSIGNED NOT NULL,
	family_id BIGINT UNSIGNED NOT NULL,
	
	PRIMARY KEY (user_id, family_id),
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (family_id) REFERENCES families(id)
);
