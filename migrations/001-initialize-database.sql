--------------------------------------------------------------------------------
-- Up
--------------------------------------------------------------------------------

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  username TEXT NOT NULL,
  avatarUrl TEXT
);

CREATE TABLE posts (
  id INTEGER PRIMARY KEY,
  createdAt INTEGER NOT NULL DEFAULT (strftime('%s000','now')), 
  imageUrls TEXT NOT NULL,
  caption TEXT NOT NULL
);

CREATE TABLE user_authored_post (
  id INTEGER PRIMARY KEY,
  userId  INTEGER NOT NULL,
  postId  INTEGER NOT NULL
);
CREATE INDEX index__user_authored_post__userId ON user_authored_post (userId);
CREATE INDEX index__user_authored_post__postId ON user_authored_post (postId);

CREATE TABLE user_liked_post (
  id INTEGER PRIMARY KEY,
  userId  INTEGER NOT NULL,
  postId  INTEGER NOT NULL
);
CREATE INDEX index__user_liked_post__userId ON user_liked_post (userId);
CREATE INDEX index__user_liked_post__postId ON user_liked_post (postId);

INSERT INTO users (username) VALUES ("Ryan"), ("Duncan"), ("Scott");


--------------------------------------------------------------------------------
-- Down
--------------------------------------------------------------------------------

DROP INDEX index__user_liked_post__postId;
DROP INDEX index__user_liked_post__userId;
DROP TABLE user_liked_post;

DROP INDEX index__user_authored_post__postId;
DROP INDEX index__user_authored_post__userId;
DROP TABLE user_authored_post;

DROP TABLE posts;
DROP TABLE users;