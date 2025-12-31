
/*1.All sub regions from EU and hierachies:*/
SELECT 
    level AS hierarchy_level,
    region_id,
    region_name,
    parent_region_id,
    LPAD(' ', (LEVEL-1)*2) || region_name AS formatted_name,
    SYS_CONNECT_BY_PATH(region_name, ' / ') AS full_path
FROM REGION
START WITH region_name = 'Europa'
CONNECT BY PRIOR region_id = parent_region_id
ORDER BY level;
/*2.All super-regions of „Toscana”*/
SELECT 
    level AS hierarchy_level,
    region_id,
    region_name,
    CONNECT_BY_ROOT region_name AS root_region,
    SYS_CONNECT_BY_PATH(region_name, ' / ') AS full_path_to_root
FROM REGION
START WITH region_name = 'Toscana'
CONNECT BY PRIOR parent_region_id = region_id;
/*3.Regions & Sub regions from „Italy”*/
SELECT 
    level AS hierarchy_level,
    region_name,
    SYS_CONNECT_BY_PATH(region_name, ' / ') AS full_path
FROM REGION
START WITH region_name = 'Italia'
CONNECT BY PRIOR region_id = parent_region_id
ORDER BY level;

/* Show all tours along with their destination and the region they belong to */
SELECT 
    t.tour_id,
    t.start_date,
    t.duration_days,
    t.price,
    d.name AS destination_name,
    r.region_name AS region_name
FROM TOUR t
JOIN DESTINATION d ON t.destination_id = d.destination_id
JOIN REGION r ON d.region_id = r.region_id
ORDER BY r.region_name, d.name;

/* 2.Count the total number of bookings for each tour */
SELECT 
    t.tour_id,
    d.name AS destination_name,
    COUNT(b.booking_id) AS total_bookings
FROM TOUR t
LEFT JOIN BOOKING b ON t.tour_id = b.tour_id
JOIN DESTINATION d ON t.destination_id = d.destination_id
GROUP BY t.tour_id, d.name
ORDER BY total_bookings DESC;

/* 3.Show the average rating of tours for each destination */
SELECT 
    d.name AS destination_name,
    AVG(rw.rating) AS avg_rating,
    COUNT(rw.review_id) AS number_of_reviews
FROM DESTINATION d
JOIN TOUR t ON d.destination_id = t.destination_id
LEFT JOIN REVIEW rw ON t.tour_id = rw.tour_id
GROUP BY d.name
HAVING COUNT(rw.review_id) > 0
ORDER BY avg_rating DESC;

/* 4.List customers who booked more than one tour */
SELECT 
    c.customer_id,
    c.name AS customer_name,
    COUNT(b.booking_id) AS bookings_count
FROM CUSTOMER c
JOIN BOOKING b ON c.customer_id = b.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(b.booking_id) > 1
ORDER BY bookings_count DESC;

/* 5. Show tours with price above the average tour price */
SELECT 
    t.tour_id,
    d.name AS destination_name,
    t.price
FROM TOUR t
JOIN DESTINATION d ON t.destination_id = d.destination_id
WHERE t.price > (SELECT AVG(price) FROM TOUR)
ORDER BY t.price DESC;

/* 6.Show for each destination the total number of bookings and average tour rating */
SELECT 
    d.name AS destination_name,
    COUNT(DISTINCT b.booking_id) AS total_bookings,
    ROUND(AVG(rw.rating),2) AS avg_rating
FROM DESTINATION d
LEFT JOIN TOUR t ON d.destination_id = t.destination_id
LEFT JOIN BOOKING b ON t.tour_id = b.tour_id
LEFT JOIN REVIEW rw ON t.tour_id = rw.tour_id
GROUP BY d.name
ORDER BY total_bookings DESC, avg_rating DESC;


/* 1.Calculate the average price of tours in the same region considering the current tour and 1 previous and 1 next tour */
SELECT 
    t.tour_id,
    d.name AS destination_name,
    r.region_name,
    t.price,
    ROUND(
        AVG(t.price) OVER (
            PARTITION BY r.region_id 
            ORDER BY t.price 
            ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
        ), 2
    ) AS avg_price_window
FROM TOUR t
JOIN DESTINATION d ON t.destination_id = d.destination_id
JOIN REGION r ON d.region_id = r.region_id
ORDER BY r.region_name, t.price;

/* 2.Show cumulative number of bookings for each tour, ordered by tour start date */
SELECT 
    t.tour_id,
    d.name AS destination_name,
    COUNT(b.booking_id) OVER (
        PARTITION BY t.tour_id 
        ORDER BY t.start_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_bookings
FROM TOUR t
LEFT JOIN BOOKING b ON t.tour_id = b.tour_id
JOIN DESTINATION d ON t.destination_id = d.destination_id
ORDER BY t.start_date;

/* 3.Show the first and last review rating for each tour based on review date */
SELECT 
    t.tour_id,
    d.name AS destination_name,
    FIRST_VALUE(rw.rating) OVER (PARTITION BY t.tour_id ORDER BY rw.review_date ASC) AS first_rating,
    LAST_VALUE(rw.rating) OVER (
        PARTITION BY t.tour_id 
        ORDER BY rw.review_date ASC 
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_rating
FROM TOUR t
JOIN DESTINATION d ON t.destination_id = d.destination_id
LEFT JOIN REVIEW rw ON t.tour_id = rw.tour_id
ORDER BY t.tour_id;

/* 4.Show the price of the previous and next tour within the same region */
SELECT 
    t.tour_id,
    d.name AS destination_name,
    r.region_name,
    t.price,
    LAG(t.price) OVER (PARTITION BY r.region_id ORDER BY t.price) AS previous_price,
    LEAD(t.price) OVER (PARTITION BY r.region_id ORDER BY t.price) AS next_price
FROM TOUR t
JOIN DESTINATION d ON t.destination_id = d.destination_id
JOIN REGION r ON d.region_id = r.region_id
ORDER BY r.region_name, t.price;

/* 5.Calculate the ratio of each customer's bookings compared to the total bookings */
SELECT 
    c.customer_id,
    c.name AS customer_name,
    COUNT(b.booking_id) AS total_bookings,
    ROUND(
        COUNT(b.booking_id) * 100.0 / SUM(COUNT(b.booking_id)) OVER (), 2
    ) AS booking_percentage
FROM CUSTOMER c
LEFT JOIN BOOKING b ON c.customer_id = b.customer_id
GROUP BY c.customer_id, c.name
ORDER BY booking_percentage DESC;

/* 6.Rank customers based on the number of tours they have booked, showing ties with DENSE_RANK */
SELECT 
    c.customer_id,
    c.name AS customer_name,
    COUNT(b.booking_id) AS total_bookings,
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank
FROM CUSTOMER c
LEFT JOIN BOOKING b ON c.customer_id = b.customer_id
GROUP BY c.customer_id, c.name
ORDER BY booking_rank, c.name;





