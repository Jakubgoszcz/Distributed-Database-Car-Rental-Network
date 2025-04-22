# 🚗 Distributed Database – Car Rental Network

## 📌 Project Overview

This project presents a distributed database system designed for a network of car rental branches. Each branch uses an **object-oriented Oracle database**, while a central **SQL Server** instance manages and coordinates the entire network.

---

## 🏢 System Architecture

### 🔹 Local Branch (Oracle)
- Object-oriented database design
- Use of packages, procedures, functions, and triggers for data integrity and access
- Responsibilities:
  - Managing clients and employees
  - Handling car rentals and returns
  - Fleet and reservation management
  - Local data analysis

### 🔸 Central Instance (SQL Server)
- Centralized management of the rental network
- Monitoring and approval of fleet vehicles
- Aggregated analysis of network-wide data
- Remote management of Oracle branches via **RPC (Remote Procedure Call)**
- Integration of Oracle data into SQL Server:
  - Using **table functions** to flatten object structures
  - **Views** (`OPENQUERY`) for up-to-date data access

### 🚘 Car Fleet Database
- Stores all vehicles that can be added to the fleet
- Handles vehicle registration and updates

---

## ⚙️ Technologies & Mechanisms

- **Oracle Database** – object-oriented schema design
- **SQL Server** – centralized coordination platform
- **RPC (Remote Procedure Call)** – remote execution of Oracle procedures
- **Table Functions + Views (`OPENQUERY`)** – integration of Oracle's object data into SQL Server
- **Replication (Merge Publication)** – ensures data synchronization between fleet DB and central instance
- **MS DTC (Distributed Transaction Coordinator)** – maintains consistency in distributed transactions

---

## 🗺️ Schema Diagrams

- **Oracle**
![image](https://github.com/user-attachments/assets/dded9e73-cf3f-452d-8d5e-a4cf8971abd3)

- **SQL Server**
![image](https://github.com/user-attachments/assets/8651c249-2058-442a-9e70-634a38a5b6fb)

---

## 📊 Project Goals

To design and implement a scalable, efficient, and secure distributed database system that:
- Allows local autonomy for each branch
- Enables centralized management and data analysis
- Ensures data consistency and synchronization across all components

