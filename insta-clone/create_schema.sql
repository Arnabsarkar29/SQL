--INSTA CLONE

-- CREATE SCHEMA

CREATE DATABASE ig_clone;
USE ig_clone;

CREATE TABLE users(
	id SERIAL PRIMARY KEY,
	username VARCHAR(255) UNIQUE NOT NULL,
	created_dt TIMESTAMP DEFAULT NOW()
);

CREATE TABLE photos(
	id SERIAL PRIMARY KEY,
	image_url VARCHAR(255) NOT NULL,
	user_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(user_id) REFERENCES users(id) 
);

CREATE TABLE user_comments(
	id SERIAL PRIMARY KEY,
	comment_text VARCHAR(255) NOT NULL,
	user_id INT NOT NULL,
	photo_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(photo_id) REFERENCES photos(id)
);

CREATE TABLE likes(
	user_id INT NOT NULL,
	photo_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(photo_id) REFERENCES photos(id),
	PRIMARY KEY(user_id , photo_id)
);

CREATE TABLE follows(
	follower_id INT NOT NULL,
	followee_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(follower_id) REFERENCES users(id),
	FOREIGN KEY(followee_id) REFERENCES users(id),
	PRIMARY KEY(follower_id , followee_id)
);

CREATE TABLE unfollows(
	follower_id INT NOT NULL,
	followee_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(follower_id) REFERENCES users(id),
	FOREIGN KEY(followee_id) REFERENCES users(id),
	PRIMARY KEY(follower_id , followee_id)
);

CREATE TABLE tags(
	id SERIAL PRIMARY KEY,
	tag_name VARCHAR(255) UNIQUE,
	created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE photo_tags(
	photo_id INT NOT NULL,
	tag_id INT NOT NULL,
	FOREIGN KEY(photo_id) REFERENCES photos(id),
	FOREIGN KEY(tag_id) REFERENCES tags(id),
	PRIMARY KEY (photo_id , tag_id)
);

-- Create Triggers 
-- Prevent self follow
CREATE OR REPLACE FUNCTION prevent_self_follows()
RETURNS TRIGGER
AS $body$
BEGIN
	IF NEW.follower_id  = NEW.followee_id THEN
		RAISE NOTICE 'Can not follow self';
	ELSE
		RETURN NEW;
	END IF;
END
$body$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_self_follow
BEFORE INSERT ON follows FOR EACH ROW
EXECUTE PROCEDURE prevent_self_follows();

--log unfollowing
CREATE OR REPLACE FUNCTION capture_unfollows()
RETURNS TRIGGER
AS $body$
BEGIN
	INSERT INTO unfollows
	VALUES (OLD.follower_id , OLD.followee_id);
	RETURN NEW;
END
$body$ LANGUAGE plpgsql;

CREATE TRIGGER capture_unfollows
AFTER DELETE ON follows FOR EACH ROW
EXECUTE PROCEDURE capture_unfollows();