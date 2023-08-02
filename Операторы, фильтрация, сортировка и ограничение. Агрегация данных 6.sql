use vk;

# 1. Из всех друзей выбранного пользователя найти человека, который больше всех общался с нашим пользователем.
# Выбираем пользователя №1.

SELECT
    from_user_id,
    (SELECT firstname FROM users WHERE id = messages.from_user_id) AS Name,
    (SELECT lastname FROM users WHERE id = messages.from_user_id) AS Surname,
    to_user_id,
    COUNT(body) AS 'Messages_sent' 
FROM messages 
WHERE from_user_id IN (
  SELECT initiator_user_id FROM friend_requests WHERE (target_user_id = 1) AND status='approved'
  UNION
  SELECT target_user_id FROM friend_requests WHERE (initiator_user_id = 1) AND status='approved'
) AND to_user_id = 1
GROUP BY from_user_id
ORDER BY Messages_sent DESC
LIMIT 1; 

# Проверяем, кто дружит с id1
 SELECT * FROM friend_requests WHERE (initiator_user_id = 1 OR target_user_id = 1)
	and status = 'approved'
# С id1 дружат 3, 4, 10

# Проверяем, кто кто в принципе писал id1
SELECT
    from_user_id,
    (SELECT firstname FROM users WHERE id = messages.from_user_id) AS Name,
    (SELECT lastname FROM users WHERE id = messages.from_user_id) AS Surname,
    to_user_id,
    COUNT(body) AS 'Messages_sent' 
FROM messages 
WHERE to_user_id=1
GROUP BY from_user_id
ORDER BY Messages_sent DESC; 
# Из друзей больше всего писал 4.

 
# 2. Подсчитаем общее количество лайков, которые получили пользователи младше 11 лет.

SELECT 
	COUNT(created_at) AS Number_of_likes
FROM likes
WHERE media_id = (
    SELECT id FROM media WHERE (likes.media_id = media.id) 
    AND user_id = (SELECT user_id FROM profiles WHERE (media.user_id = profiles.user_id) AND (YEAR(NOW())-YEAR(birthday)) < 11)
);

# Для проверки, какие пользователи с возрастом младше 11 лет?
SELECT user_id 
FROM profiles 
WHERE (YEAR(NOW())-YEAR(birthday)) < 11;

# Теперь, какие у них медиа?
SELECT id
FROM media
WHERE user_id = (
	SELECT user_id FROM profiles WHERE (media.user_id = profiles.user_id) AND (YEAR(NOW())-YEAR(birthday)) < 11
);
# В таблице с лайками видно, что в принципе лайки были поставлены медиа с id <= 20. Скрипт в этом даипазоне выдал id 7, но, согласно таблице, это медиа не лайкали. Значит, подсчёт сработал верно. 

# Дополнительно, проверим, есть ли у этих медиа лайки?
SELECT id
FROM likes
WHERE media_id = (
    SELECT id FROM media WHERE (likes.media_id = media.id) 
    AND user_id = (SELECT user_id FROM profiles WHERE (media.user_id = profiles.user_id) AND (YEAR(NOW())-YEAR(birthday)) < 11)
);
# Результат - лайки отсутствуют, что и подтвердил подсчёт в решении.


# 3. Определим, кто больше поставил лайков (всего): мужчины или женщины.

SELECT 
	(SELECT gender FROM profiles WHERE likes.user_id = profiles.user_id) AS 'Gender',
	COUNT(id) AS Number_of_likes
FROM likes 
GROUP BY Gender
LIMIT 1;

# Для проверки, добавляем пол в таблицу с лайками.
SELECT 
	*,
	(SELECT gender FROM profiles WHERE likes.user_id= profiles.user_id) AS Gender
FROM likes;
# Действительно, только 4 лайка были от мужчин. 