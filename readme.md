### Airport Management System - Project Documentation

This repository contains files and documentation for the **Airport Management System**, a database-driven application designed to handle various aspects of airport operations. The system was developed as part of the **Applied Computer Science** curriculum at AGH University of Krakow.

## Project Overview
The **Airport Management System** is designed to streamline and automate airport operations by managing flights, reservations, passengers, crew members, and infrastructure. It is built using a **relational database** and a **PHP-based web interface**, ensuring efficient data management and user accessibility.

### Key Features:
- **Flight Management**: Create, update, and delete flight schedules.
- **Reservation System**: Manage passenger bookings and cancellations.
- **Fleet and Crew Management**: Assign aircraft and personnel to specific flights.
- **Infrastructure Management**: Oversee airport terminals, gates, and facilities.
- **User Roles**: Admin and client accounts with role-based access control.

## Project Structure
### **1. Database Files (`sql/` folder)**
This folder contains SQL scripts necessary for setting up and managing the database:
- **`baza_backup.sql`** - A backup of the full database.
- **`baza_ddl.sql`** - The database schema including tables, relationships, and constraints.
- **`kwerendy.sql`** - SQL queries used in the system.
- **`kod.sql`** - Table definitions and database logic.
- **`widoki.sql`** - SQL views for data aggregation and reporting.
- **`wyzwalacze.sql`** - Database triggers for automated operations.

### **2. Application Files (`public_html/` folder)**
This folder contains the PHP-based web application responsible for interacting with the database:
- **`auth.php`** - User authentication (login, logout, and session handling).
- **`db.php`** - Database connection and interaction functions.
- **`flota.php`** - Fleet management, including aircraft and crew assignment.
- **`loty.php`** - Flight scheduling and modifications.
- **`rezerwacje_loty.php`** - Handling passenger reservations.
- **`infrastruktura.php`** - Management of terminals and gates.
- **`użytkownicy.php`** - Admin panel for user role management.
- **`functions.php`** - Helper functions used throughout the system.
- **CSS folder** - Stylesheets for the web interface.

## Deployment Instructions
To set up the **Airport Management System** locally:
1. Import the SQL scripts in the `sql/` folder into a **PostgreSQL** database.
2. Configure the **database connection** in `db.php`.
3. Deploy the `public_html/` folder on a local or remote **PHP server**.
4. Access the system through the web interface and log in with predefined admin or client credentials.

## Notes
- The database is designed for daily renewal when hosted on a **remote server**.
- If connection issues arise, the database may need to be reinitialized.
- The project documentation includes a **PDF** file with additional technical details.

This project demonstrates the integration of **database management** and **web development** for an airport operational system, ensuring efficient handling of core functionalities such as flight scheduling, reservations, and infrastructure monitoring.
