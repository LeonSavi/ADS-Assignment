-- Ensuring that if run the same script twice all the tables are deleted
-- to avoid conflicts
DROP TABLE IF EXISTS status;
DROP TABLE IF EXISTS bill;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS partner;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS ref_customers;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS branch;
DROP TABLE IF EXISTS sector_tbl;
DROP TABLE IF EXISTS country_tbl;
DROP TABLE IF EXISTS bill_item;

   
-- ASSUMPTIONS: B2B, we are working in IT components industry, we resell components to clients (no private companies), we have partners that provide us some components

-- main features about the customers, without going in too deep about the emails,
-- as they can have different emails depending on role/department/branch

-- country ID
CREATE TABLE country_tbl (
    country_code CHAR(2) PRIMARY KEY, -- NL
    country VARCHAR UNIQUE NOT NULL, -- netherlands
    country_phone_code INTEGER UNIQUE NOT NULL-- 0031/+31
);
-- SECTOR
CREATE TABLE sector_tbl (
    sector_code CHAR(3) PRIMARY KEY, -- s12
    sector VARCHAR UNIQUE NOT NULL, -- Financial Institution
    sector_desc VARCHAR UNIQUE NOT NULL -- Financial entities, such as banks, 
);
-- Our company location
CREATE TABLE branch (
    branch_id INTEGER PRIMARY KEY,
    name VARCHAR NOT NULL,
    city VARCHAR NOT NULL,
    country VARCHAR NOT NULL,
    FOREIGN KEY(country) REFERENCES country_tbl(country)
);
-- customers main features (og table)
CREATE TABLE customer (
    customer_id INTEGER PRIMARY KEY,
    company_name VARCHAR NOT NULL,
    sector_code CHAR(3),
    country VARCHAR NOT NULL,
    street VARCHAR NOT NULL,
    house_number VARCHAR NOT NULL,
    zip_code VARCHAR NOT NULL, 
    city VARCHAR NOT NULL,
    FOREIGN KEY(sector_code) REFERENCES sector_tbl(sector_code),
    FOREIGN KEY(country) REFERENCES country_tbl(country)
);
-- refence contact of our customers
CREATE TABLE ref_customers (
    reference_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    role VARCHAR NOT NULL, -- sales
    email VARCHAR UNIQUE NOT NULL,
    country VARCHAR NOT NULL,
    country_phone_code INTEGER,
    phone_number INTEGER,
    FOREIGN KEY(customer_id) REFERENCES customer(customer_id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY(country,country_phone_code) REFERENCES country_tbl(country,country_phone_code) ON UPDATE CASCADE ON DELETE SET NULL
);
-- company emplyees
CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    branch_id INTEGER,
    role VARCHAR NOT NULL CHECK(role IN ('External', 'Manager', 'Salesman', 'HR')),
    department VARCHAR NOT NULL CHECK(department IN ('Sales', 'HR', 'R&D', 'Management')),
    email VARCHAR NOT NULL,
    phone_number INTEGER NOT NULL,
    FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON UPDATE CASCADE ON DELETE CASCADE -- if branch bye bye, bye bye also employees
);
-- our partners location: https://en.wikipedia.org/wiki/Business_partner
-- maybe to connect better to other tables
CREATE TABLE partner (
    partner_id INTEGER PRIMARY KEY,
    company_name VARCHAR NOT NULL,
    country VARCHAR NOT NULL,
    products_and_services VARCHAR NOT NULL,
    contact_person VARCHAR NOT NULL,
    contact_email VARCHAR NOT NULL,
    FOREIGN KEY(country) REFERENCES country_tbl(country) ON UPDATE CASCADE
);
-- items we sell
CREATE TABLE items (
    item_id INTEGER PRIMARY KEY, -- 001
    tech_name VARCHAR NOT NULL, -- Nvidia RTX 5060
    partner_id VARCHAR NOT NULL,
    buy_price FLOAT NOT NULL,
    FOREIGN KEY(partner_id) REFERENCES partner(partner_id) ON UPDATE CASCADE ON DELETE SET NULL
);
-- Items sold informations, info the status should be in another table e.g. status
CREATE TABLE bill (
    bill_id INTEGER PRIMARY KEY,
    branch_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    date DATE NOT NULL,
    amount FLOAT NOT NULL,
    payment_method VARCHAR CHECK(payment_method IN ('Credit Card', 'IBAN', 'Cash')),
    ref_employee_id INTEGER, -- Usually someone from sales
    ref_cust_id INTEGER,
    FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON UPDATE CASCADE,
    FOREIGN KEY(customer_id) REFERENCES customer(customer_id) ON UPDATE CASCADE,
    FOREIGN KEY(ref_employee_id) REFERENCES employees(employee_id) ON UPDATE CASCADE,
    FOREIGN KEY(ref_cust_id) REFERENCES ref_customers(reference_id) ON UPDATE CASCADE
);
-- Status of our invoices
CREATE TABLE status (
    bill_id INTEGER,
    update_date DATE DEFAULT CURRENT_TIMESTAMP,
    status_items VARCHAR NOT NULL,
    status_payment VARCHAR NOT NULL,
    refund_request INTEGER DEFAULT 0,
    PRIMARY KEY (bill_id, update_date),
    FOREIGN KEY (bill_id) REFERENCES bill(bill_id) ON UPDATE CASCADE ON DELETE CASCADE
);
-- bill_item: basically what we sold
CREATE TABLE bill_item (
    bill_id INTEGER,
    item_id INTEGER,
    quantity INTEGER NOT NULL,
    price FLOAT NOT NULL,
    PRIMARY KEY (bill_id, item_id),
    FOREIGN KEY(bill_id) REFERENCES bill(bill_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY(item_id) REFERENCES items(item_id) ON UPDATE CASCADE
);


-- Insert countries
INSERT INTO country_tbl (country_code, country, country_phone_code) VALUES
('NL', 'Netherlands', 0031),
('DE', 'Germany', 0049),
('FR', 'France', 0033),
('IT', 'Italy', 0039),
('GR', 'Greece', 0030),
('ES', 'Spain', 0034),
('PT', 'Portugal', 00351),
('BE', 'Belgium', 0032),
('US', 'United States', 001),
('CN', 'China', 0086);

-- Insert sectors
INSERT INTO sector_tbl (sector_code, sector, sector_desc) VALUES
('S01', 'Financial Institution', 'Banks, insurance companies'),
('S02', 'Technology', 'Hardware and software companies'),
('S03', 'Retail', 'Consumer goods retailers'),
('S04', 'Manufacturing', 'Producers of hardware components'),
('S05', 'Logistics', 'Transport and warehousing providers'),
('S06', 'Healthcare', 'Medical tech companies'),
('S07', 'Education', 'Universities and training centres'),
('S08', 'Energy', 'Energy and utilities providers'),
('S09', 'Consulting', 'Advisory firms'), 
('S10', 'Telecom', 'Telecommunications companies');
-- Insert branches
INSERT INTO branch (branch_id, name, city, country) VALUES
(1, 'HQ Amsterdam', 'Amsterdam', 'Netherlands'),
(2, 'Berlin Office', 'Berlin', 'Germany'),
(3, 'France Office', 'Paris', 'France'),
(4, 'Rome Office', 'Rome', 'Italy'),
(5, 'Madrid Hub', 'Madrid', 'Spain'),
(6, 'Lisbon Office', 'Lisbon', 'Portugal'),
(7, 'Brussels Office', 'Brussels', 'Belgium'),
(8, 'New York Office', 'New York', 'United States'),
(9, 'Shanghai Hub', 'Shanghai', 'China'),
(10, 'Athens Office', 'Athens', 'Greece');

-- Insert customers
INSERT INTO customer (customer_id, company_name, sector_code, country, street, house_number, zip_code, city) VALUES
(1, 'TechRetail BV', 'S03', 'Netherlands', 'Keizersgracht', '221', '1016', 'Amsterdam'),
(2, 'FinBank AG', 'S01', 'Germany', 'Unter den Linden', '45', '10117', 'Berlin'),
(3, 'MedTech SA', 'S06', 'France', 'Rue Lafayette', '12', '75009', 'Paris'),
(4, 'EduGlobal BV', 'S07', 'Netherlands', 'Damrak', '50', '1012', 'Amsterdam'),
(5, 'LogiTrans GmbH', 'S05', 'Germany', 'Friedrichstrasse', '60', '10117', 'Berlin'),
(6, 'EnergyCorp', 'S08', 'Italy', 'Via Roma', '33', '00184', 'Rome'),
(7, 'ConsultPlus', 'S09', 'Spain', 'Gran Via', '101', '28013', 'Madrid'),
(8, 'TeleCom NL', 'S10', 'Netherlands', 'Leidsestraat', '200', '1017', 'Amsterdam'),
(9, 'RetailMax', 'S03', 'Portugal', 'Rua Augusta', '150', '1100', 'Lisbon'),
(10, 'BankSecure', 'S01', 'Belgium', 'Rue Royale', '75', '1000', 'Brussels');

-- Insert customer references
INSERT INTO ref_customers (reference_id, customer_id, role, email, country, country_phone_code, phone_number) VALUES
(101, 1, 'Purchasing Manager', 'pm@techretail.nl', 'Netherlands', 0031, 612345678),
(102, 2, 'Head of Procurement', 'procurement@finbank.de', 'Germany', 0049, 172345678),
(103, 3, 'Head of Procurement', 'proc@medtech.fr', 'France', 0033, 612222333),
(104, 4, 'IT Manager', 'it@eduglobal.nl', 'Netherlands', 0031, 612333444),
(105, 5, 'Logistics Lead', 'logi@logitrans.de', 'Germany', 0049, 172111222),
(106, 6, 'Energy Buyer', 'buyer@energy.it', 'Italy', 0039, 331444555),
(107, 7, 'Senior Consultant', 'contact@consultplus.es', 'Spain', 0034, 699555666),
(108, 8, 'Network Manager', 'network@telecom.nl', 'Netherlands', 0031, 612777888),
(109, 9, 'Retail Buyer', 'buyer@retailmax.pt', 'Portugal', 00351, 962333444),
(110, 10, 'Risk Manager', 'risk@banksecure.be', 'Belgium', 0032, 477999111);

-- Insert employees
INSERT INTO employees (employee_id, branch_id, role, department, email, phone_number) VALUES
(1, 1, 'Manager', 'Sales', 'sales_manager@hq.nl', 612000001),
(2, 1, 'Salesman', 'Sales', 'rep1@hq.nl', 612000002),
(3, 2, 'Salesman', 'Sales', 'rep2@berlin.de', 49170000003),
(4, 3, 'Salesman', 'Sales', 'rep3@paris.fr', 3310000004),
(5, 4, 'Manager', 'Management', 'manager@rome.it', 3906000005),
(6, 5, 'Salesman', 'Sales', 'sales@madrid.es', 3469000006),
(7, 6, 'HR', 'HR', 'hr@lisbon.pt', 3512100007),
(8, 7, 'Salesman', 'Sales', 'rep@brussels.be', 3227000008),
(9, 8, 'External', 'R&D', 'consultant@ny.us', 1212000009),
(10, 9, 'Manager', 'Management', 'manager@shanghai.cn', 861380000010);

-- Insert partners
INSERT INTO partner (partner_id, company_name, country, products_and_services, contact_person, contact_email) VALUES
(1, 'Nvidia Corp', 'US', 'gpu', 'Alice Johnson', 'alice@nvidia.com'),
(2, 'Intel GmbH', 'Germany', 'cpu', 'Max Müller', 'max@intel.de'),
(3, 'AMD Inc.', 'US', 'cpu', 'John Sbo', 'john@amd.com'),
(4, 'ASML', 'Netherlands', 'semiconductors', 'Eva Jansen', 'eva@asml.nl'),
(5, 'Samsung Electronics', 'China', 'memory', 'Li Wei', 'liwei@samsung.cn'),
(6, 'TSMC', 'Taiwan', 'chips', 'Chen Lin', 'chen@tsmc.com'),
(7, 'Cisco Systems', 'United States', 'networking', 'Michael Brown', 'michael@cisco.com'),
(8, 'Seagate', 'United States', 'storage', 'Samantha Green', 'sam@seagate.com'),
(9, 'Micron', 'United States', 'memory', 'Robert White', 'robert@micron.com'),
(10, 'Lenovo', 'China', 'laptops', 'Zhang Li', 'zhang@lenovo.cn');

-- Insert items
INSERT INTO items (item_id, tech_name, partner_id, buy_price) VALUES
(1, 'Nvidia RTX 4060', 1, 250.00),
(2, 'Intel i7 14700K', 2, 300.00),
(3, 'Nvidia RTX 4090', 1, 1500.00),
(4, 'AMD Ryzen 7 9800X3D', 3, 450.00),
(5, 'AMD Ryzen 9 9950X3D', 3, 650.00),
(6, 'ASML Lithography Machine', 4, 120000.00),
(7, 'Samsung DDR5 32GB', 5, 150.00),
(8, 'TSMC Custom Chipset', 6, 500.00),
(9, 'Cisco Router 9000', 7, 2000.00),
(10, 'Lenovo ThinkPad X1', 10, 1200.00);

-- Insert bills
INSERT INTO bill (bill_id, branch_id, customer_id, date, amount, payment_method, ref_employee_id, ref_cust_id) VALUES
(1, 1, 1, '2025-09-01', 1250.00, 'IBAN', 2, 101),
(2, 2, 2, '2025-09-05', 3000.00, 'Credit Card', 3, 102),
(3, 3, 3, '2025-09-07', 600.00, 'Cash', 4, 103),
(4, 4, 4, '2025-09-08', 1200.00, 'IBAN', 5, 104),
(5, 5, 5, '2025-09-09', 2200.00, 'Credit Card', 6, 105),
(6, 6, 6, '2025-09-10', 500.00, 'IBAN', 7, 106),
(7, 7, 7, '2025-09-11', 1800.00, 'Cash', 8, 107),
(8, 8, 8, '2025-09-12', 3500.00, 'IBAN', 9, 108),
(9, 9, 9, '2025-09-13', 1500.00, 'Credit Card', 10, 109),
(10, 10, 10, '2025-09-14', 4000.00, 'IBAN', 8, 110),
(11, 1, 1, '2025-09-15', 2200.00, 'IBAN', 2, 101),
(12, 2, 5, '2025-09-16', 800.00, 'Credit Card', 3, 105);

-- Insert bill items
INSERT INTO bill_item (bill_id, item_id, quantity, price) VALUES
(1, 1, 2, 400.00),   -- 2 RTX 4060 sold for 400 each
(1, 2, 1, 450.00),   -- 1 Intel i7 sold for 450
(2, 3, 2, 1600.00),  -- 2 RTX 4090 sold for 1600 each
(3, 7, 2, 200.00),
(4, 10, 1, 1500.00),
(5, 9, 1, 2500.00),
(6, 8, 2, 700.00),
(7, 6, 1, 130000.00),
(8, 2, 5, 350.00),
(9, 5, 3, 700.00),
(10, 1, 10, 500.00),
(11, 8, 3, 600.00),   -- TSMC Chipset
(11, 9, 2, 2200.00),  -- Cisco Router
(12, 7, 10, 180.00),  -- Samsung DDR5
(12, 10, 5, 1300.00); -- Lenovo ThinkPad

-- Insert statuses
INSERT INTO status (bill_id, update_date, status_items, status_payment, refund_request) VALUES
-- Bill 1 (agreement 2025-09-01)
(1, '2025-09-01', 'Preparing', 'Pending', 0),
(1, '2025-09-02', 'Shipped',   'Payed', 0),
(1, '2025-09-04', 'Delivered', 'Payed', 0),

-- Bill 2 (agreement 2025-09-05)
(2, '2025-09-05', 'Preparing', 'Pending', 0),
(2, '2025-09-06', 'Shipped',   'Pending', 0),
(2, '2025-09-08', 'Delivered', 'Payed', 0),

-- Bill 3 (agreement 2025-09-07)
(3, '2025-09-07', 'Preparing', 'Pending', 0),
(3, '2025-09-08', 'Shipped',   'Payed', 0),

-- Bill 4 (agreement 2025-09-08)
(4, '2025-09-08', 'Preparing', 'Pending', 0),
(4, '2025-09-09', 'Shipped',   'Pending', 0),
(4, '2025-09-11', 'Delivered', 'Payed', 0),

-- Bill 5 (agreement 2025-09-09)
(5, '2025-09-09', 'Preparing', 'Pending', 0),
(5, '2025-09-10', 'Shipped',   'Payed', 0),

-- Bill 6 (agreement 2025-09-10)
(6, '2025-09-10', 'Preparing', 'Pending', 0),
(6, '2025-09-11', 'Shipped',   'Payed', 0),

-- Bill 7 (agreement 2025-09-11)
(7, '2025-09-11', 'Preparing', 'Pending', 0),
(7, '2025-09-12', 'Shipped',   'Pending', 0),
(7, '2025-09-13', 'Delivered', 'Payed', 0),

-- Bill 8 (agreement 2025-09-12)
(8, '2025-09-12', 'Preparing', 'Pending', 0),
(8, '2025-09-13', 'Shipped',   'Pending', 0),
(8, '2025-09-15', 'Delivered', 'Payed', 0),

-- Bill 9 (agreement 2025-09-13)
(9, '2025-09-13', 'Preparing', 'Pending', 0),
(9, '2025-09-14', 'Shipped',   'Payed', 1),  -- Refund requested after delivery

-- Bill 10 (agreement 2025-09-14)
(10, '2025-09-14', 'Preparing', 'Pending', 0),
(10, '2025-09-15', 'Shipped',   'Pending', 0),
(10, '2025-09-16', 'Delivered', 'Payed', 0),

-- Bill 11 (agreement 2025-09-15)
(11, '2025-09-15', 'Preparing', 'Pending', 0),
(11, '2025-09-16', 'Shipped',   'Pending', 0),

-- Bill 12 (agreement 2025-09-16)
(12, '2025-09-16', 'Preparing', 'Pending', 0),
(12, '2025-09-17', 'Shipped',   'Payed', 0);
