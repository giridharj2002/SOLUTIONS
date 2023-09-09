/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), 
 both first name and last name are in upper case, customer_email,  customer_creation_year 
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date,
 no permanent change in the table is required. (Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables
 for your representation. A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.) 
*/

SELECT CUSTOMER_ID, 
       CONCAT(case when CUSTOMER_GENDER='M' then "Mr." when CUSTOMER_GENDER='F' then "Ms" end,'.', UPPER(CUSTOMER_FNAME), ' ',  UPPER(CUSTOMER_LNAME)) AS customer_full_name, 
       customer_email, 
       year(CUSTOMER_CREATION_DATE) as customer_creation_year, 
       CASE 
           WHEN year(CUSTOMER_CREATION_DATE) < 2005 THEN 'A' 
           WHEN year(CUSTOMER_CREATION_DATE) >= 2005 AND year(CUSTOMER_CREATION_DATE) < 2011 THEN 'B' 
           WHEN year(CUSTOMER_CREATION_DATE) >= 2011 THEN 'C' 
       END AS customer_category 
FROM ONLINE_CUSTOMER;



/* Q2. Write a query to display the following information for the products which
 have not been sold: product_id, product_desc, product_quantity_avail, product_price,
 inventory values (product_quantity_avail * product_price), New_Price after applying discount
 as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 20,000 then apply 20% discount 
ii) If Product Price > 10,000 then apply 15% discount 
iii) if Product Price =< 10,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.)
*/
SELECT product_id, 
       product_desc, 
       product_quantity_avail, 
       product_price, 
       (product_quantity_avail * product_price) AS inventory_value, 
       CASE 
           WHEN product_price > 20000 THEN product_price * 0.8 
           WHEN product_price > 10000 THEN product_price * 0.85 
           ELSE product_price * 0.9 
       END AS new_price 
FROM PRODUCT 
WHERE product_id NOT IN (SELECT product_id FROM ORDER_ITEMS) 
ORDER BY inventory_value DESC;



/*Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price). Information should be displayed for only those
 product_class_code which have more than 1,00,000 Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

SELECT 
  PRODUCT_CLASS.product_class_code, 
  PRODUCT_CLASS.product_class_desc, 
  COUNT(PRODUCT.product_id) AS count_of_product_type, 
  SUM(PRODUCT.product_quantity_avail * PRODUCT.product_price) AS inventory_value
FROM PRODUCT
JOIN PRODUCT_CLASS ON PRODUCT.product_class_code = PRODUCT_CLASS.product_class_code
GROUP BY PRODUCT_CLASS.product_class_code, PRODUCT_CLASS.product_class_desc
HAVING SUM(PRODUCT.product_quantity_avail * PRODUCT.product_price) > 100000
ORDER BY inventory_value DESC
LIMIT 9;



/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY
*/
 
SELECT
    OC.CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS FULL_NAME,
    OC.CUSTOMER_EMAIL,
    OC.CUSTOMER_PHONE,
    A.COUNTRY
FROM
    ONLINE_CUSTOMER AS OC
JOIN
    ADDRESS AS A ON OC.ADDRESS_ID = A.ADDRESS_ID
WHERE
    OC.CUSTOMER_ID NOT IN (
        SELECT DISTINCT OH.CUSTOMER_ID
        FROM ORDER_HEADER AS OH
        WHERE OH.ORDER_STATUS <> 'Cancelled'
    )
AND
    OC.CUSTOMER_ID IN (
        SELECT DISTINCT OH.CUSTOMER_ID
        FROM ORDER_HEADER AS OH
    );



/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city ,
 number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. The main intent is to find the number
 of customers and the consignments catered by DHL in each city.
 */

SELECT 
  SHIPPER.shipper_name, 
  ADDRESS.city, 
  COUNT(DISTINCT ONLINE_CUSTOMER.customer_id) AS num_of_customers, 
  COUNT(ORDER_HEADER.order_id) AS num_of_consignments
FROM SHIPPER
JOIN ORDER_HEADER ON SHIPPER.shipper_id = ORDER_HEADER.shipper_id
JOIN ONLINE_CUSTOMER ON ORDER_HEADER.customer_id = ONLINE_CUSTOMER.customer_id
JOIN ADDRESS ON ONLINE_CUSTOMER.address_id = ADDRESS.address_id
WHERE SHIPPER.shipper_name = 'DHL'
GROUP BY SHIPPER.shipper_name, ADDRESS.city
ORDER BY num_of_consignments DESC
LIMIT 9;  



/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and 
show inventory Status of products as per below condition: 

a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status (Low stock, In stock, and Enough stock)
 that meets both the conditions i.e. on products as well as on quantity.
The meaning of the rest of the categories, means products apart from electronics, computers, mobiles, and watches.
*/

SELECT
    P.PRODUCT_ID,
    P.PRODUCT_DESC,
    P.PRODUCT_QUANTITY_AVAIL,
    SUM(OI.PRODUCT_QUANTITY) AS QUANTITY_SOLD,
    CASE
        WHEN PC.PRODUCT_CLASS_DESC IN ('Electronics', 'Computer') THEN
            CASE
                WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.1 * SUM(OI.PRODUCT_QUANTITY) THEN 'Low inventory, need to add inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.5 * SUM(OI.PRODUCT_QUANTITY) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        WHEN PC.PRODUCT_CLASS_DESC IN ('Mobiles', 'Watches') THEN
            CASE
                WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.2 * SUM(OI.PRODUCT_QUANTITY) THEN 'Low inventory, need to add inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.6 * SUM(OI.PRODUCT_QUANTITY) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        ELSE
            CASE
                WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.3 * SUM(OI.PRODUCT_QUANTITY) THEN 'Low inventory, need to add inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.7 * SUM(OI.PRODUCT_QUANTITY) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
    END AS INVENTORY_STATUS
FROM
    PRODUCT AS P
JOIN
    PRODUCT_CLASS AS PC ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
LEFT JOIN
    ORDER_ITEMS AS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
GROUP BY
    P.PRODUCT_ID, P.PRODUCT_DESC, P.PRODUCT_QUANTITY_AVAIL, PC.PRODUCT_CLASS_DESC
ORDER BY
    P.PRODUCT_ID;    



/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having total volume less than the volume of carton id 10
 */

SELECT
    OI.ORDER_ID,
    SUM(P.LEN * P.WIDTH * P.HEIGHT) AS ORDER_VOLUME
FROM
    ORDER_ITEMS AS OI
JOIN
    PRODUCT AS P
ON
    OI.PRODUCT_ID = P.PRODUCT_ID
WHERE
    OI.ORDER_ID IN (
        SELECT DISTINCT OH.ORDER_ID
        FROM ORDER_HEADER AS OH
        WHERE OH.ORDER_STATUS = 'Shipped'
    )
GROUP BY
    OI.ORDER_ID
HAVING
    ORDER_VOLUME <= (
        SELECT SUM(P.LEN * P.WIDTH * P.HEIGHT) AS CARTON_VOLUME
        FROM CARTON AS C
        WHERE C.CARTON_ID = 10
    )
ORDER BY
    ORDER_VOLUME DESC
LIMIT 1;



/*Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/

SELECT
    OC.CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS CUSTOMER_FULL_NAME,
    SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY_SHIPPED,
    SUM(OI.PRODUCT_QUANTITY * P.PRODUCT_PRICE) AS TOTAL_VALUE_SHIPPED
FROM
    ONLINE_CUSTOMER AS OC
JOIN
    ORDER_HEADER AS OH ON OC.CUSTOMER_ID = OH.CUSTOMER_ID
JOIN
    ORDER_ITEMS AS OI ON OH.ORDER_ID = OI.ORDER_ID
JOIN
    PRODUCT AS P ON OI.PRODUCT_ID = P.PRODUCT_ID
WHERE
    OH.PAYMENT_MODE = 'Cash'
    AND OC.CUSTOMER_LNAME LIKE 'G%'
GROUP BY
    OC.CUSTOMER_ID, OC.CUSTOMER_FNAME, OC.CUSTOMER_LNAME
HAVING
    SUM(OI.PRODUCT_QUANTITY) > 0
ORDER BY
    OC.CUSTOMER_ID;



/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products , 
 product_id’s which are sold with 201 product_id (201 should not be there in output) and are shipped except Bangalore and New Delhi
 */

SELECT 
  PRODUCT.product_id, 
  PRODUCT.product_desc, 
  SUM(ORDER_ITEMS.product_quantity) AS total_quantity
FROM ORDER_ITEMS
JOIN PRODUCT ON ORDER_ITEMS.product_id = PRODUCT.product_id
JOIN ORDER_HEADER ON ORDER_ITEMS.order_id = ORDER_HEADER.order_id
JOIN ONLINE_CUSTOMER ON ORDER_HEADER.customer_id = ONLINE_CUSTOMER.customer_id
JOIN ADDRESS ON ONLINE_CUSTOMER.address_id = ADDRESS.address_id
WHERE ORDER_ITEMS.product_id != 201
AND ORDER_ITEMS.product_id IN (
  SELECT product_id
  FROM ORDER_ITEMS
  WHERE order_id IN (
    SELECT order_id
    FROM ORDER_ITEMS
    WHERE product_id = 201
  )
)
AND ADDRESS.city NOT IN ('Bangalore', 'New Delhi')
GROUP BY PRODUCT.product_id, PRODUCT.product_desc
ORDER BY total_quantity DESC;



/* Q10. Write a query to display the order_id, customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]	
 */
SELECT
    OH.ORDER_ID,
    OC.CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS CUSTOMER_FULLNAME,
    SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY_SHIPPED
FROM
    ORDER_HEADER AS OH
JOIN
    ONLINE_CUSTOMER AS OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
JOIN
    ORDER_ITEMS AS OI ON OH.ORDER_ID = OI.ORDER_ID
JOIN
    ADDRESS AS A ON OC.ADDRESS_ID = A.ADDRESS_ID
WHERE
    OH.ORDER_ID % 2 = 0
    AND NOT A.PINCODE LIKE '5%'
GROUP BY
    OH.ORDER_ID, OC.CUSTOMER_ID, CUSTOMER_FULLNAME
ORDER BY
    OH.ORDER_ID;    
