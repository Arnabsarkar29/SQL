-- Oldest users
SELECT * FROM users
ORDER BY created_dt
LIMIT 5;

-- DAY with user registration
SELECT TO_CHAR("created_dt" , 'Day') AS day_of_week , COUNT(id) as total
FROM users
GROUP BY day_of_week ORDER BY total DESC;

-- USERNAME who never posted
SELECT username FROM users WHERE id IN  
(SELECT id FROM users EXCEPT SELECT user_id FROM photos);

--User posted the most popular photo
WITH like_count AS(
	SELECT photo_id , COUNT(user_id) as no_of_likes FROM likes
	GROUP BY photo_id),
	photo_id AS(
	SELECT photo_id FROM like_count
	WHERE no_of_likes = (SELECT MAX(no_of_likes) FROM like_count))

SELECT user_id , image_url FROM photos WHERE id = (SELECt * FROM photo_id);

--How many times average user post
SELECT ROUND((SELECT COUNT(id) FROM photos)::DECIMAL / (SELECT COUNT(id) FROM users)::DECIMAL , 3) as avg_photo_posted;

-- 5 trending hastags
SELECT id , tag_name , used_no
FROM tags JOIN 
(SELECT tag_id, COUNT(tag_id) AS used_no
FROM photo_tags
GROUP BY  tag_id ORDER BY used_no DESC LIMIT 5) AS A 
ON A.tag_id = tags.id
ORDER BY used_no DESC;

-- FIND users liked all photo
SELECT id , username 
FROM users 
WHERE NOT EXISTS
	(SELECT id FROM photos EXCEPT 
	SELECT photo_id FROM likes 
	WHERE likes.user_id = users.id);

-- INSERT follows CHECK trigger works
INSERT INTO follows
VALUES (10,10);

-- DELETE follows CHECK trigger works
DELETE FROM follows
WHERE ( follower_id , followee_id) = (10,11);

-- CHECK unfollows
SELECT * FROM unfollows;

-- Show triggers
SELECT
    trigger_schema,
    trigger_name,
    event_manipulation,
    action_statement
FROM information_schema.triggers;


