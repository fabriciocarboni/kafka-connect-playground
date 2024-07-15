SELECT 'Starting database setup...' AS 'INFO';

CREATE DATABASE IF NOT EXISTS demo;
GRANT ALL PRIVILEGES ON demo.* TO 'mysqluser'@'%';

CREATE DATABASE IF NOT EXISTS freetestapi;
GRANT ALL PRIVILEGES ON freetestapi.* TO 'mysqluser'@'%';

SELECT 'Database setup completed.' AS 'INFO';
