SET PAGESIZE 200
SET LINESIZE 200
SET FEEDBACK ON
SET VERIFY OFF

===== BAI 1: TAO BANG VA NHAP DU LIEU =====

BEGIN EXECUTE IMMEDIATE 'DROP TABLE s_inventory PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE s_item PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE s_ord PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE s_warehouse PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE s_customer PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE s_emp PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE s_dept PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE s_product PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE s_image PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE s_longtext PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE s_title PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE s_region PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/

CREATE TABLE s_region (
    id NUMBER(7) CONSTRAINT s_region_id_pk PRIMARY KEY,
    name VARCHAR2(50) NOT NULL
);

CREATE TABLE s_title (
    title VARCHAR2(25) CONSTRAINT s_title_title_pk PRIMARY KEY
);

CREATE TABLE s_dept (
    id NUMBER(7) CONSTRAINT s_dept_id_pk PRIMARY KEY,
    name VARCHAR2(25) NOT NULL,
    region_id NUMBER(7) CONSTRAINT s_dept_region_id_fk REFERENCES s_region(id)
);

CREATE TABLE s_longtext (
    id NUMBER(7) CONSTRAINT s_longtext_id_pk PRIMARY KEY,
    use_filename CHAR(1) CHECK (use_filename IN ('Y','N')),
    filename VARCHAR2(255),
    text CLOB
);

CREATE TABLE s_image (
    id NUMBER(7) CONSTRAINT s_image_id_pk PRIMARY KEY,
    format VARCHAR2(15),
    use_filename CHAR(1) CHECK (use_filename IN ('Y','N')),
    filename VARCHAR2(255),
    image BLOB
);

CREATE TABLE s_product (
    id NUMBER(7) CONSTRAINT s_product_id_pk PRIMARY KEY,
    name VARCHAR2(50) NOT NULL,
    short_desc VARCHAR2(255),
    longtext_id NUMBER(7) CONSTRAINT s_product_longtext_id_fk REFERENCES s_longtext(id),
    image_id NUMBER(7) CONSTRAINT s_product_image_id_fk REFERENCES s_image(id),
    suggested_whlsl_price NUMBER(11,2),
    whlsl_units VARCHAR2(25)
);

CREATE TABLE s_emp (
    id NUMBER(7) CONSTRAINT s_emp_id_pk PRIMARY KEY,
    last_name VARCHAR2(25) NOT NULL,
    first_name VARCHAR2(25),
    userid VARCHAR2(8) CONSTRAINT s_emp_userid_uq UNIQUE,
    start_date DATE,
    comments VARCHAR2(255),
    manager_id NUMBER(7),
    title VARCHAR2(25),
    dept_id NUMBER(7),
    salary NUMBER(11,2),
    commission_pct NUMBER(4,2),
    CONSTRAINT s_emp_title_fk FOREIGN KEY (title) REFERENCES s_title(title),
    CONSTRAINT s_emp_dept_id_fk FOREIGN KEY (dept_id) REFERENCES s_dept(id)
);

ALTER TABLE s_emp
ADD CONSTRAINT s_emp_manager_id_fk FOREIGN KEY (manager_id) REFERENCES s_emp(id);

CREATE TABLE s_customer (
    id NUMBER(7) CONSTRAINT s_customer_id_pk PRIMARY KEY,
    name VARCHAR2(50) NOT NULL,
    phone VARCHAR2(25),
    address VARCHAR2(100),
    city VARCHAR2(30),
    state VARCHAR2(20),
    country VARCHAR2(30),
    zip_code VARCHAR2(12),
    credit_rating VARCHAR2(10),
    sales_rep_id NUMBER(7),
    region_id NUMBER(7),
    comments VARCHAR2(255),
    CONSTRAINT s_customer_sales_rep_id_fk FOREIGN KEY (sales_rep_id) REFERENCES s_emp(id),
    CONSTRAINT s_customer_region_id_fk FOREIGN KEY (region_id) REFERENCES s_region(id)
);

CREATE TABLE s_warehouse (
    id NUMBER(7) CONSTRAINT s_warehouse_id_pk PRIMARY KEY,
    region_id NUMBER(7) CONSTRAINT s_warehouse_region_id_fk REFERENCES s_region(id),
    address VARCHAR2(100),
    city VARCHAR2(30),
    state VARCHAR2(20),
    country VARCHAR2(30),
    zip_code VARCHAR2(12),
    phone VARCHAR2(25),
    manager_id NUMBER(7) CONSTRAINT s_warehouse_manager_id_fk REFERENCES s_emp(id)
);

CREATE TABLE s_ord (
    id NUMBER(7) CONSTRAINT s_ord_id_pk PRIMARY KEY,
    customer_id NUMBER(7) CONSTRAINT s_ord_customer_id_fk REFERENCES s_customer(id),
    date_ordered DATE,
    date_shipped DATE,
    sales_rep_id NUMBER(7) CONSTRAINT s_ord_sales_rep_id_fk REFERENCES s_emp(id),
    total NUMBER(11,2),
    payment_type VARCHAR2(20),
    order_filled CHAR(1) CHECK (order_filled IN ('Y','N'))
);

CREATE TABLE s_item (
    ord_id NUMBER(7),
    item_id NUMBER(7),
    product_id NUMBER(7) CONSTRAINT s_item_product_id_fk REFERENCES s_product(id),
    price NUMBER(11,2),
    quantity NUMBER(9),
    quantity_shipped NUMBER(9),
    CONSTRAINT s_item_pk PRIMARY KEY (ord_id, item_id),
    CONSTRAINT s_item_ord_id_fk FOREIGN KEY (ord_id) REFERENCES s_ord(id)
);

CREATE TABLE s_inventory (
    product_id NUMBER(7),
    warehouse_id NUMBER(7),
    amount_in_stock NUMBER(9),
    reorder_point NUMBER(9),
    max_in_stock NUMBER(9),
    out_of_stock_explanation VARCHAR2(255),
    restock_date DATE,
    CONSTRAINT s_inventory_pk PRIMARY KEY (product_id, warehouse_id),
    CONSTRAINT s_inventory_product_id_fk FOREIGN KEY (product_id) REFERENCES s_product(id),
    CONSTRAINT s_inventory_warehouse_id_fk FOREIGN KEY (warehouse_id) REFERENCES s_warehouse(id)
);

INSERT INTO s_region VALUES (1, 'North America');
INSERT INTO s_region VALUES (2, 'South America');
INSERT INTO s_region VALUES (3, 'Asia');

INSERT INTO s_title VALUES ('Director');
INSERT INTO s_title VALUES ('Manager');
INSERT INTO s_title VALUES ('Sales Rep');
INSERT INTO s_title VALUES ('Clerk');

INSERT INTO s_dept VALUES (10, 'Head Office', 1);
INSERT INTO s_dept VALUES (31, 'Retail East', 1);
INSERT INTO s_dept VALUES (42, 'Support Asia', 3);
INSERT INTO s_dept VALUES (50, 'Online Sales', 2);

INSERT INTO s_longtext VALUES (1, 'N', NULL, 'Mountain bicycle for trail and city riding.');
INSERT INTO s_longtext VALUES (2, 'N', NULL, 'Professional ski boot for winter sport.');
INSERT INTO s_longtext VALUES (3, 'N', NULL, 'Helmet and safety accessory package.');
INSERT INTO s_longtext VALUES (4, 'N', NULL, 'Daily commuter bicycle with basket.');

INSERT INTO s_image VALUES (1, 'jpg', 'N', 'pro_mtb.jpg', EMPTY_BLOB());
INSERT INTO s_image VALUES (2, 'jpg', 'N', 'ski_boots.jpg', EMPTY_BLOB());
INSERT INTO s_image VALUES (3, 'jpg', 'N', 'pro_helmet.jpg', EMPTY_BLOB());
INSERT INTO s_image VALUES (4, 'jpg', 'N', 'city_bicycle.jpg', EMPTY_BLOB());

INSERT INTO s_product VALUES (1001, 'Pro Mountain Bike', 'High performance bicycle for mountain trail', 1, 1, 1200, 'Each');
INSERT INTO s_product VALUES (1002, 'Ski Boots', 'Comfort ski boots for winter trips', 2, 2, 350, 'Pair');
INSERT INTO s_product VALUES (1003, 'Pro Helmet', 'Safety helmet for bicycle and ski', 3, 3, 80, 'Each');
INSERT INTO s_product VALUES (1004, 'City Bicycle', 'Everyday bicycle for commuting in city', 4, 4, 600, 'Each');

INSERT INTO s_emp VALUES (100, 'Nguyen', 'Lan', 'lan', TO_DATE('15/05/1990','DD/MM/YYYY'), NULL, NULL, 'Director', 10, 4500, 0.20);
INSERT INTO s_emp VALUES (101, 'Tran', 'Son', 'son', TO_DATE('20/05/1991','DD/MM/YYYY'), NULL, 100, 'Manager', 10, 3200, 0.10);
INSERT INTO s_emp VALUES (102, 'Le', 'Susan', 'susan', TO_DATE('10/01/1991','DD/MM/YYYY'), NULL, 101, 'Sales Rep', 50, 1800, 0.05);
INSERT INTO s_emp VALUES (103, 'Pham', 'Liam', 'liam', TO_DATE('18/06/1992','DD/MM/YYYY'), NULL, 101, 'Sales Rep', 31, 1600, 0.04);
INSERT INTO s_emp VALUES (104, 'Do', 'Smith', 'smith', TO_DATE('03/03/1991','DD/MM/YYYY'), NULL, 101, 'Clerk', 42, 1700, 0.02);

BEGIN
  FOR i IN 1..21 LOOP
    INSERT INTO s_emp (
      id, last_name, first_name, userid, start_date, comments, manager_id, title, dept_id, salary, commission_pct
    ) VALUES (
      200 + i,
      'Staff' || TO_CHAR(i),
      'Sale' || TO_CHAR(i),
      'u' || TO_CHAR(200 + i),
      TO_DATE('01/01/1992','DD/MM/YYYY') + i,
      NULL,
      101,
      'Sales Rep',
      50,
      1200 + (i * 35),
      0.03
    );
  END LOOP;
END;
/

INSERT INTO s_customer VALUES (201, 'An Khang Trading', '0900000001', '12 Main St', 'HCM', 'HCM', 'Vietnam', '700000', 'A', 102, 3, NULL);
INSERT INTO s_customer VALUES (202, 'Global Sport', '0900000002', '99 Ocean Ave', 'Da Nang', 'DN', 'Vietnam', '550000', 'B', 103, 3, NULL);
INSERT INTO s_customer VALUES (203, 'Pro Riders Club', '0900000003', '20 Lake Rd', 'Ha Noi', 'HN', 'Vietnam', '100000', 'A', 102, 1, NULL);
INSERT INTO s_customer VALUES (204, 'Winter Shop', '0900000004', '8 Snow St', 'Can Tho', 'CT', 'Vietnam', '900000', 'B', 104, 2, NULL);
INSERT INTO s_customer VALUES (205, 'No Order Customer', '0900000005', '1 Empty Rd', 'Hue', 'HU', 'Vietnam', '530000', 'C', 103, 2, 'Chua dat hang');

INSERT INTO s_warehouse VALUES (1, 1, '100 Warehouse Rd', 'New York', 'NY', 'USA', '10001', '111-1111', 100);
INSERT INTO s_warehouse VALUES (2, 2, '200 Depot St', 'Sao Paulo', 'SP', 'Brazil', '01000', '222-2222', 101);
INSERT INTO s_warehouse VALUES (3, 3, '300 Logistic Ave', 'Singapore', 'SG', 'Singapore', '018989', '333-3333', 101);

INSERT INTO s_ord VALUES (101, 201, TO_DATE('05/01/2024','DD/MM/YYYY'), TO_DATE('07/01/2024','DD/MM/YYYY'), 102, 150000, 'CASH', 'Y');
INSERT INTO s_ord VALUES (102, 202, TO_DATE('10/01/2024','DD/MM/YYYY'), TO_DATE('15/01/2024','DD/MM/YYYY'), 103, 95000, 'CARD', 'Y');
INSERT INTO s_ord VALUES (103, 201, TO_DATE('12/01/2024','DD/MM/YYYY'), TO_DATE('20/01/2024','DD/MM/YYYY'), 102, 250000, 'TRANSFER', 'Y');
INSERT INTO s_ord VALUES (104, 204, TO_DATE('15/01/2024','DD/MM/YYYY'), NULL, 104, 120000, 'CASH', 'N');

INSERT INTO s_item VALUES (101, 1, 1001, 1200, 50, 50);
INSERT INTO s_item VALUES (101, 2, 1003, 80, 60, 60);
INSERT INTO s_item VALUES (102, 1, 1004, 600, 80, 80);
INSERT INTO s_item VALUES (103, 1, 1002, 350, 300, 300);
INSERT INTO s_item VALUES (103, 2, 1003, 80, 100, 100);
INSERT INTO s_item VALUES (104, 1, 1001, 1200, 100, 20);

INSERT INTO s_inventory VALUES (1001, 1, 300, 50, 1000, NULL, TO_DATE('01/02/2024','DD/MM/YYYY'));
INSERT INTO s_inventory VALUES (1002, 2, 500, 100, 1200, NULL, TO_DATE('05/02/2024','DD/MM/YYYY'));
INSERT INTO s_inventory VALUES (1003, 3, 700, 150, 1500, NULL, TO_DATE('07/02/2024','DD/MM/YYYY'));
INSERT INTO s_inventory VALUES (1004, 1, 200, 60, 900, NULL, TO_DATE('03/02/2024','DD/MM/YYYY'));

COMMIT;


PROMPT
PROMPT ===== BAI 2: TRUY VAN CO BAN =====

PROMPT C1
SELECT name AS "Ten khach hang",
       id AS "Ma khach hang"
FROM s_customer
ORDER BY id DESC;

PROMPT C2
SELECT first_name || ' ' || last_name AS "Employees",
       dept_id
FROM s_emp
WHERE dept_id IN (10, 50)
ORDER BY first_name;

PROMPT C3
SELECT last_name, first_name
FROM s_emp
WHERE first_name LIKE '%S%'
   OR last_name LIKE '%S%';

PROMPT C4
SELECT userid, start_date
FROM s_emp
WHERE start_date BETWEEN TO_DATE('14/05/1990','DD/MM/YYYY')
                     AND TO_DATE('26/05/1991','DD/MM/YYYY');

PROMPT C5
SELECT last_name, salary
FROM s_emp
WHERE salary BETWEEN 1000 AND 2000;

PROMPT C6
SELECT last_name || ' ' || first_name AS "Employee Name",
       salary AS "Monthly Salary"
FROM s_emp
WHERE dept_id IN (31, 42, 50)
  AND salary > 1350;

PROMPT C7
SELECT last_name, start_date
FROM s_emp
WHERE start_date BETWEEN TO_DATE('01/01/1991','DD/MM/YYYY')
                     AND TO_DATE('31/12/1991','DD/MM/YYYY');

PROMPT C8
SELECT last_name, first_name
FROM s_emp
WHERE id NOT IN (
    SELECT DISTINCT manager_id
    FROM s_emp
    WHERE manager_id IS NOT NULL
);

PROMPT C9
SELECT name
FROM s_product
WHERE name LIKE 'Pro%'
ORDER BY name ASC;

PROMPT C10
SELECT name, short_desc
FROM s_product
WHERE LOWER(short_desc) LIKE '%bicycle%';

PROMPT C11
SELECT short_desc
FROM s_product;

PROMPT C12
SELECT last_name || ' ' || first_name || ' (' || title || ')' AS "Nhan vien"
FROM s_emp;

PROMPT
PROMPT ===== BAI 3: CAC LOAI HAM =====

PROMPT C1
SELECT id,
       last_name,
       ROUND(salary * 1.15, 2) AS "Luong moi"
FROM s_emp;

PROMPT C2
SELECT last_name,
       start_date,
       TO_CHAR(
         NEXT_DAY(ADD_MONTHS(start_date, 6), 'MONDAY'),
         'Ddspth "of" Month YYYY'
       ) AS "Ngay xet tang luong"
FROM s_emp;

PROMPT C3
SELECT name
FROM s_product
WHERE LOWER(name) LIKE '%ski%';

PROMPT C4
SELECT last_name,
       ROUND(MONTHS_BETWEEN(SYSDATE, start_date)) AS "So thang tham nien"
FROM s_emp
ORDER BY MONTHS_BETWEEN(SYSDATE, start_date) ASC;

PROMPT C5
SELECT COUNT(DISTINCT manager_id) AS "So nguoi quan ly"
FROM s_emp
WHERE manager_id IS NOT NULL;

PROMPT C6
SELECT MAX(total) AS "Highest",
       MIN(total) AS "Lowest"
FROM s_ord;

PROMPT
PROMPT ===== BAI 4: JOIN =====

PROMPT C1
SELECT p.name,
       p.id,
       i.quantity AS "ORDERED"
FROM s_product p, s_item i
WHERE p.id = i.product_id
  AND i.ord_id = 101;

PROMPT C2
SELECT c.id AS "Ma khach hang",
       o.id AS "Ma don hang"
FROM s_customer c LEFT JOIN s_ord o
ON c.id = o.customer_id
ORDER BY c.id;

PROMPT C3
SELECT o.customer_id,
       i.product_id,
       i.quantity
FROM s_ord o, s_item i
WHERE o.id = i.ord_id
  AND o.total > 100000;

PROMPT
PROMPT ===== BAI 5: HAM GOP NHOM =====

PROMPT C1
SELECT manager_id AS "Ma quan ly",
       COUNT(id) AS "So nhan vien"
FROM s_emp
WHERE manager_id IS NOT NULL
GROUP BY manager_id
ORDER BY manager_id;

PROMPT C2
SELECT manager_id AS "Ma quan ly",
       COUNT(id) AS "So nhan vien"
FROM s_emp
WHERE manager_id IS NOT NULL
GROUP BY manager_id
HAVING COUNT(id) >= 20;

PROMPT C3
SELECT r.id AS "Ma vung",
       r.name AS "Ten vung",
       COUNT(d.id) AS "So phong ban"
FROM s_region r, s_dept d
WHERE r.id = d.region_id
GROUP BY r.id, r.name
ORDER BY r.id;

PROMPT C4
SELECT c.name AS "Ten khach hang",
       COUNT(o.id) AS "So don dat hang"
FROM s_customer c, s_ord o
WHERE c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY c.name;

PROMPT C5
SELECT c.name, COUNT(o.id) AS "So don hang"
FROM s_customer c, s_ord o
WHERE c.id = o.customer_id
GROUP BY c.id, c.name
HAVING COUNT(o.id) = (
  SELECT MAX(COUNT(id))
  FROM s_ord
  GROUP BY customer_id
);

PROMPT C6
SELECT c.name, SUM(o.total) AS "Tong tien"
FROM s_customer c, s_ord o
WHERE c.id = o.customer_id
GROUP BY c.id, c.name
HAVING SUM(o.total) = (
  SELECT MAX(SUM(total))
  FROM s_ord
  GROUP BY customer_id
);

PROMPT
PROMPT ===== BAI 6: SUBQUERY =====

SELECT last_name, first_name, start_date
FROM s_emp
WHERE dept_id IN (
    SELECT dept_id
    FROM s_emp
    WHERE first_name = 'Lan'
)
AND first_name != 'Lan';

SELECT id, last_name, first_name, userid
FROM s_emp
WHERE salary > (SELECT AVG(salary) FROM s_emp);

SELECT id, last_name, first_name
FROM s_emp
WHERE salary > (SELECT AVG(salary) FROM s_emp)
  AND (UPPER(first_name) LIKE '%L%'
   OR  UPPER(last_name) LIKE '%L%');

SELECT c.name
FROM s_customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM s_ord o
    WHERE o.customer_id = c.id
);

