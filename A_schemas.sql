-- library mangement system project 2
CREATE DATABASE bproject;
use bproject;

DROP TABLE IF EXISTS EMPLOYEE;

create table branch(
branch_id VARCHAR(10) PRIMARY KEY,
manager_id VARCHAR(10),
branch_address VARCHAR(10),
contact_no VARCHAR(10)
);

ALTER TABLE branch
MODIFY branch_address varchar(75);

CREATE TABLE EMPLOYEE (
emp_id	VARCHAR(20) PRIMARY KEY,
emp_name VARCHAR(25),
position VARCHAR(15),
salary INT,	
branch_id VARCHAR(25)
);

ALTER TABLE employee
MODIFY emp_name VARCHAR(75);

DROP TABLE IF EXISTS BOOKS;

CREATE TABLE BOOKS(
isbn VARCHAR(20) PRIMARY KEY ,
book_title	VARCHAR(75) ,
category VARCHAR(15),
rental_price FLOAT, 
status VARCHAR (20),
author	VARCHAR(35),
publisher VARCHAR(55)
);

ALTER TABLE books
MODIFY COLUMN category VARCHAR(25);

CREATE TABLE MEMBERS(
member_id VARCHAR(5) PRIMARY KEY,
member_name	VARCHAR(20),
member_address	VARCHAR(20),
reg_date DATE
);

CREATE TABLE ISSUED_STATUS(
issued_id VARCHAR(10) PRIMARY KEY,
issued_member_id VARCHAR(10) ,
issued_book_name VARCHAR(75),
issued_date	DATE,
issued_book_isbn VARCHAR(25),
issued_emp_id VARCHAR(15) 
);

CREATE TABLE RETURN_STATUS(
return_id VARCHAR(10) PRIMARY KEY,
issued_id VARCHAR(10) ,
return_book_name VARCHAR(75),
return_date	DATE,
return_book_isbn VARCHAR(25)
);

-- FOREIGN KEY
ALTER TABLE ISSUED_STATUS
ADD CONSTRAINT fk_member
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE RETURN_STATUS
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);
