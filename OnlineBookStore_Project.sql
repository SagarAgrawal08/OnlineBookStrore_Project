-- Create Database
CREATE DATABASE OnlineBookstore;

-- Switch to the database
\c OnlineBookstore;

-- Create Tables
DROP TABLE IF EXISTS Books;
CREATE TABLE Books (
    Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);
DROP TABLE IF EXISTS customers;
CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);
DROP TABLE IF EXISTS orders;
CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2)
);

SELECT * FROM Books;
SELECT * FROM Customers;
SELECT * FROM Orders;


-- Import Data into Books Table
COPY Books(Book_ID, Title, Author, Genre, Published_Year, Price, Stock) 
FROM 'D:\SQL\Practice file\ST - SQL ALL PRACTICE FILES\All Excel Practice Files\Books.csv' 
CSV HEADER;

-- Import Data into Customers Table
COPY Customers(Customer_ID, Name, Email, Phone, City, Country) 
FROM 'D:\SQL\Practice file\ST - SQL ALL PRACTICE FILES\All Excel Practice Files\Customers.csv' 
CSV HEADER;

-- Import Data into Orders Table
COPY Orders(Order_ID, Customer_ID, Book_ID, Order_Date, Quantity, Total_Amount) 
FROM 'D:\SQL\Practice file\ST - SQL ALL PRACTICE FILES\All Excel Practice Files\Orders.csv' 
CSV HEADER;


-- 1) Retrieve all books in the "Fiction" genre:
SELECT * FROM BOOKS
WHERE genre='Fiction';


-- 2) Find books published after the year 1950:
SELECT title, published_year FROM BOOKS
WHERE published_year>1950;


-- 3) List all customers from the Canada:
SELECT * FROM Customers;

SELECT * FROM customers
WHERE country='Canada';

-- 4) Show orders placed in November 2023:
SELECT * FROM Orders;

SELECT * FROM orders
WHERE order_date BETWEEN '2023-11-1' AND '2023-11-30';


-- 5) Retrieve the total stock of books available:
SELECT * FROM books;

SELECT SUM(stock) AS total_stock FROM books;

-- 6) Find the details of the most expensive book:
SELECT * FROM books;

SELECT * FROM books
ORDER BY price desc
LIMIT 1;

-- 7) Show all customers who ordered more than 1 quantity of a book:
SELECT * FROM orders
WHERE quantity>1;


-- 8) Retrieve all orders where the total amount exceeds $20:
SELECT * FROM orders;

SELECT * FROM orders
WHERE total_amount > 20;


-- 9) List all genres available in the Books table:
SELECT * FROM Books;

SELECT
DISTINCT genre
FROM books;

-- 10) Find the book with the lowest stock:
SELECT * FROM Books;

SELECT title, stock FROM books
ORDER BY stock
LIMIT 2;

-- 11) Calculate the total revenue generated from all orders:
SELECT * FROM orders;

SELECT SUM(total_amount) AS revenue FROM orders;


-- Advance Questions : 

-- 1) Retrieve the total number of books sold for each genre:
SELECT * FROM books;
SELECT * FROM orders;

SELECT DISTINCT b.genre AS dis_genre,
	SUM(o.quantity) OVER(PARTITION BY b.genre) AS Total_Book_Sold
from books b
JOIN
orders o
ON b.book_id=o.book_id;


SELECT b.genre, SUM(o.quantity) AS Total_Book_Sold
from books b
JOIN
orders o
ON b.book_id=o.book_id
GROUP BY b.genre;



-- 2) Find the average price of books in the "Fantasy" genre:
SELECT * FROM books;

SELECT AVG(price) AS avg_price
FROM books
WHERE genre='Fantasy';


SELECT genre, AVG(price) AS avg_price
FROM books
WHERE genre='Fantasy'
GROUP BY genre;


-- 3) List customers who have placed at least 2 orders:
SELECT * FROM customers;
SELECT * FROM Orders;

SELECT customer_id, count(order_id) AS order_count
FROM orders
GROUP BY customer_id
HAVING count(order_id) >=2;


SELECT o.customer_id, c.name, count(o.order_id) AS order_count
FROM orders o
JOIN customers c ON o.customer_id=c.customer_id
GROUP BY o.customer_id, c.name
HAVING count(o.order_id) >=2;



-- 4) Find the most frequently ordered book:
SELECT * FROM Orders;
SELECT * FROM Books;

SELECT book_id, COUNT(order_id)
FROM orders
GROUP BY book_id
ORDER BY COUNT(order_id) DESC LIMIT 1;


SELECT book_id, COUNT(order_id) AS order_count
FROM orders
GROUP BY book_id
ORDER BY order_count DESC LIMIT 1;


SELECT o.book_id, b.title, COUNT(o.order_id) AS order_count
FROM orders o
JOIN books b ON o.book_id=b.book_id
GROUP BY o.book_id, b.title
ORDER BY order_count DESC LIMIT 1;



-- 5) Show the top 3 most expensive books of 'Fantasy' Genre :
SELECT * FROM Books;

SELECT * FROM Books
WHERE genre='Fantasy'
ORDER BY price DESC LIMIT 3;

-- 6) Retrieve the total quantity of books sold by each author:
SELECT * FROM Books;
SELECT * FROM Orders;

SELECT b.author, SUM(o.quantity) AS Books_sold
FROM orders o
JOIN books b ON b.book_id=o.book_id
GROUP BY b.author;


SELECT b.author, SUM(o.quantity) AS Books_sold
FROM orders o
JOIN books b ON b.book_id=o.book_id
GROUP BY b.author
ORDER BY books_sold DESC;



-- 7) List the cities where customers who spent over $30 are located:
SELECT * FROM customers;
SELECT * FROM orders;

--List the cities where all customers who spent over $30 are located
SELECT c.city, SUM(o.total_amount) AS spent_amount
FROM orders o
JOIN customers c ON c.customer_id=o.customer_id
GROUP BY c.city
HAVING SUM(o.total_amount) > 400
ORDER BY spent_Amount;

--List the cities where customers who spent over $30 are located
SELECT DISTINCT c.city, o.total_amount AS spent_amount
FROM orders o
JOIN customers c ON c.customer_id=o.customer_id
WHERE o.total_amount > 400;



-- 8) Find the customer who spent the most on orders:
SELECT c.customer_id, c.name, SUM(o.total_amount) AS spent_amount
FROM orders o
JOIN customers c ON c.customer_id=o.customer_id
GROUP BY c.name, c.customer_id
ORDER BY spent_Amount DESC LIMIT 1;

--9) Calculate the stock remaining after fulfilling all orders:
SELECT * FROM orders;
SELECT * FROM books;

SELECT b.book_id, b.title, b.stock, COALESCE(SUM(o.quantity),0),
		b.stock - COALESCE(SUM(o.quantity),0) AS remaining_books
FROM books b
LEFT JOIN Orders o ON b.book_id=o.book_id
GROUP BY b.book_id
ORDER BY book_id;

