# Python-Driven UI for Advanced SQL Database Operations

### 1. Project Overview
A powerful web-based application built using Python (Streamlit) that enables users to interact with a MySQL database without writing any SQL code. This project bridges the gap between complex backend data structures and non-technical business users by providing a seamless, real-time inventory management dashboard.

### 2. Purpose
In the real world, many managers and team leads need to work with data stored in databases but lack SQL expertise. The purpose of this application is to help those users perform critical tasks—such as viewing inventory, updating stock, and generating reports—through a simple, click-based interface. It abstracts the complexity of database management while maintaining robust data integrity in the backend.

### 3. Tech Stack
The dashboard and database were built using the following tools and technologies:
* **Python (Streamlit):** The frontend framework used to build the interactive web UI, allowing for real-time data filtering and operational controls.
* **MySQL Database:** A relational database backend designed with advanced SQL features, including Stored Procedures, Views, and Triggers to enforce business logic.
* **MySQL Connector & Pandas:** Used to establish secure connections between the Python application and the database, and to structure query results into readable DataFrames.

### 4. Data Source
The project relies on a custom-built relational database (`advanced_sql`) that simulates a real-world supply chain. The data structure includes:
* **Products & Inventory:** Tracks product names, categories, pricing, current stock quantities, and reorder levels.
* **Suppliers:** Manages supplier contact details mapped to specific products.
* **Stock Entries & Shipments:** Logs historical data for received shipments, daily sales, and stock adjustments.
* **Reorders:** Tracks the lifecycle of purchase orders from "Pending" to "Received."

### 5. Features

#### Business Problem
Operational leads often need to interact directly with inventory data to make purchasing decisions but cannot safely query or update the database directly. Manual database administration for tasks like "Receiving an Order" increases the risk of human error and data corruption.

#### Goal of the Dashboard
* **User Accessibility:** Create a tool that non-tech users can use to see live results and manage inventory without writing SQL.
* **Full-Stack Integration:** Ensure seamless communication between the frontend and backend, triggering complex SQL stored procedures via simple UI buttons.

#### Walkthrough of Key Modules
* **Basic Metrics Dashboard:** Instant visibility into Total Sales Value, Restock Value, Active Suppliers, and alerts for products below their reorder level.
* **Operational Tasks:**
    * **Add New Product:** A streamlined form that securely inserts new product records and auto-generates associated shipment logs using a backend stored procedure (`AddNewProduct`).
    * **Product History:** A view that tracks the complete lifecycle (Shipments, Sales, and Reorders) for any selected product.
    * **Place & Receive Reorders:** Dedicated interfaces to place new orders and mark pending ones as "Received," which automatically updates stock quantities via the `MarkReorderAsReceived` transaction.

### 6. Business Impact & Insights
* **Operational Efficiency:** Drastically reduces the time required to manage inventory by automating multi-step database updates (e.g., updating stock, logging shipments, and closing reorders) into single-click actions.
* **Data Integrity:** Utilizes SQL transaction blocks (`START TRANSACTION`, `COMMIT`) within stored procedures to ensure that financial and inventory records remain accurate and synchronized at all times.
* **Scalable Architecture:** Demonstrates how businesses can define rules within the database layer, ensuring that business logic is consistently applied regardless of the user interface.
