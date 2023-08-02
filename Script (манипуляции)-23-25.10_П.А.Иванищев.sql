USE vk;

# 2. Скрипт, возвращающий список имен (только firstname) пользователей без повторений в алфавитном порядке.
SELECT distinct firstname
FROM users;

# 3. Первые пять пользователей пометить как удаленные.
UPDATE users
SET 
	is_deleted = 1
WHERE
	id <=5;

# 3. Более универсальный скрипт.
UPDATE users
SET 
	is_deleted = 1
LIMIT 5;

# 4. Скрипт, удаляющий сообщения «из будущего» (дата больше сегодняшней).
DELETE FROM messages 
WHERE created_at > NOW()