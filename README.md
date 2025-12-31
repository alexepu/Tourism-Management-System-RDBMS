# Tourism-Management-System
Tourism Management System allows managing destinations, tours, customers, bookings, and reviews. The database is designed to store detailed information about travel regions, tourist destinations, organized tours, and customer interactions.

# Database Project Description

## Overview
The chosen theme for this database project is a **Tourism Management System**, designed to manage destinations, tours, customers, bookings, and reviews. The database stores detailed information about travel regions, tourist destinations, organized tours, and customer interactions, enabling efficient data organization and analysis.

## Tables and Their Roles

### 1. REGION
This table represents a hierarchical structure of geographic regions, including continents, countries, and sub-regions. Each region can have a parent region (`parent_region_id`), allowing hierarchical queries to navigate the geographic structure.

**Example:** Toscana is a sub-region of Italy, which is part of Europe.

### 2. DESTINATION
This table contains specific tourist destinations (cities or locations) linked to a particular region through `region_id`. Each destination has a name and country and is associated with a region from the `REGION` table.

**Example:** Florence belongs to Toscana in Italy.

### 3. TOUR
This table stores information about organized tours offered at specific destinations. It includes details such as start date, duration, and price. Each tour is linked to a destination through `destination_id`.

### 4. CUSTOMER
This table stores information about customers, including name, age, address, city, and country. Customers can make bookings and write reviews for the tours they participate in.

### 5. BOOKING
This table records bookings made by customers for specific tours. Each booking references a customer and a tour and includes the booking date. This enables tracking of which customers have booked which tours.

### 6. REVIEW
This table stores customer reviews for tours, including a numeric rating and textual feedback (`comment_text`). Each review references both a customer and a tour, allowing analysis of customer satisfaction.

## Relationships Between Tables

- **REGION → DESTINATION:** One region can have multiple destinations.
- **DESTINATION → TOUR:** One destination can host multiple tours.
- **CUSTOMER → BOOKING:** One customer can make multiple bookings.
- **TOUR → BOOKING:** One tour can have multiple bookings.
- **CUSTOMER → REVIEW:** One customer can provide multiple reviews.
- **TOUR → REVIEW:** One tour can receive multiple reviews from different customers.
