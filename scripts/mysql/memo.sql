-- 1. optimization for email domain search with generated column
ALTER TABLE users ADD COLUMN email_domain VARCHAR(255) GENERATED ALWAYS AS (SUBSTRING_INDEX(email, '@', -1)) VIRTUAL;
ALTER TABLE users ADD INDEX idx_email_domain (email_domain);

-- Before
SELECT email FROM users WHERE email LIKE "%example.com" LIMIT 2000;

-- After
SELECT email FROM users WHERE email_domain = "example.com" LIMIT 2000;

-- 2. optimization for email domain search with fulltext index
ALTER TABLE users ADD FULLTEXT INDEX idx_fulltext_email (email);

-- Before
SELECT email FROM users WHERE email LIKE "%example.com" LIMIT 2000;

-- After
SELECT email FROM users WHERE MATCH(email) AGAINST('*example.com' IN BOOLEAN MODE) LIMIT 2000;

-- 3. optimization for email domain search with generated column for sorting
ALTER TABLE users ADD COLUMN email_domain VARCHAR(255) GENERATED ALWAYS AS (SUBSTRING_INDEX(email, '@', -1)) VIRTUAL;
ALTER TABLE users ADD INDEX idx_email_domain_last_login_at (email_domain, last_login_at);

-- Before
SELECT email FROM users WHERE email LIKE "%example.com" ORDER BY last_login_at LIMIT 2000;

-- After
SELECT email FROM users WHERE email_domain = "example.com" ORDER BY last_login_at LIMIT 2000;
