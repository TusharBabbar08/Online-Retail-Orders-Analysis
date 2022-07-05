----- 07 -----
select carton.CARTON_ID, min((carton.LEN * carton.HEIGHT * carton.WIDTH)) as VOLUME 
from carton 
where 
(carton.LEN * carton.HEIGHT * carton.WIDTH) >= (select sum(product.HEIGHT * product.WIDTH * product.LEN * order_items.PRODUCT_QUANTITY) as sum_vol 
from order_items, product where order_items.ORDER_ID = 10006 and order_items.PRODUCT_ID = product.PRODUCT_ID);
--------------


----- 08 -----
SELECT 
	online_customer.CUSTOMER_ID,
    concat(online_customer.CUSTOMER_FNAME, ' ', online_customer.CUSTOMER_LNAME) as CUSTOMER_NAME,
    order_header.ORDER_ID,
    sum_table.SUM_OF_QTY
FROM
	(SELECT order_items.ORDER_ID, sum(order_items.PRODUCT_QUANTITY) as SUM_OF_QTY
	FROM order_items
	GROUP BY order_items.ORDER_ID
	HAVING sum(order_items.PRODUCT_QUANTITY) > 10) as sum_table,
    order_header,
    online_customer
WHERE
	sum_table.ORDER_ID = order_header.ORDER_ID AND
    order_header.CUSTOMER_ID = online_customer.CUSTOMER_ID AND
    order_header.ORDER_STATUS = 'Shipped';
--------------


----- 09 -----
SELECT 
	ORDER_HEADER.ORDER_ID, 
	ONLINE_CUSTOMER.CUSTOMER_ID,
	concat(ONLINE_CUSTOMER.CUSTOMER_FNAME, ' ', ONLINE_CUSTOMER.CUSTOMER_LNAME) as CUSTOMER_NAME,
	ORDER_QUANTITY_TABLE.PROD_QUANTITY
FROM 
	ORDER_HEADER,
	ONLINE_CUSTOMER,
	(SELECT ORDER_ITEMS.ORDER_ID, SUM(ORDER_ITEMS.PRODUCT_QUANTITY) as PROD_QUANTITY FROM ORDER_ITEMS GROUP BY ORDER_ITEMS.ORDER_ID HAVING ORDER_ITEMS.ORDER_ID > 10060) as ORDER_QUANTITY_TABLE
WHERE
	ORDER_HEADER.CUSTOMER_ID = ONLINE_CUSTOMER.CUSTOMER_ID AND
	ORDER_HEADER.ORDER_STATUS = 'Shipped' AND
	ORDER_HEADER.ORDER_ID = ORDER_QUANTITY_TABLE.ORDER_ID;
--------------


----- 10 -----
SELECT
	product_class.PRODUCT_CLASS_DESC,
    sum(opq.PRODUCT_QUANTITY) as total_qty,
	sum(product.PRODUCT_PRICE * opq.PRODUCT_QUANTITY) as total_value
FROM
	(SELECT 
		order_items.ORDER_ID,
		order_items.PRODUCT_ID,
		order_items.PRODUCT_QUANTITY
	FROM
		(SELECT 
			order_header.ORDER_ID, 
			customer_country.COUNTRY,
			order_header.ORDER_STATUS
		FROM
			(SELECT online_customer.CUSTOMER_ID, address.COUNTRY
			FROM online_customer, address
			WHERE
				online_customer.ADDRESS_ID = address.ADDRESS_ID AND
				address.COUNTRY NOT IN ('India', 'USA')) as customer_country,
			order_header
		WHERE 
			order_header.CUSTOMER_ID = customer_country.CUSTOMER_ID AND
			order_header.ORDER_STATUS = 'Shipped') as och,
		order_items
	WHERE
		order_items.ORDER_ID = och.ORDER_ID) as opq,
	product, 
    product_class
WHERE
	opq.PRODUCT_ID = product.PRODUCT_ID AND
    product_class.PRODUCT_CLASS_CODE = product.PRODUCT_CLASS_CODE
GROUP BY product.PRODUCT_CLASS_CODE
HAVING sum(opq.PRODUCT_QUANTITY) = 
	(SELECT
		max(ft.total_qty) as HIGHEST_QTY
	FROM
		(SELECT 
			product.PRODUCT_CLASS_CODE,
			sum(product.PRODUCT_PRICE * opq.PRODUCT_QUANTITY) as total_value,
			sum(opq.PRODUCT_QUANTITY) as total_qty
		FROM
			(SELECT 
				order_items.ORDER_ID,
				order_items.PRODUCT_ID,
				order_items.PRODUCT_QUANTITY
			FROM
				(SELECT 
					order_header.ORDER_ID, 
					customer_country.COUNTRY,
					order_header.ORDER_STATUS
				FROM
					(SELECT online_customer.CUSTOMER_ID, address.COUNTRY
					FROM online_customer, address
					WHERE
						online_customer.ADDRESS_ID = address.ADDRESS_ID AND
						address.COUNTRY NOT IN ('India', 'USA')) as customer_country,
					order_header
				WHERE 
					order_header.CUSTOMER_ID = customer_country.CUSTOMER_ID AND
					order_header.ORDER_STATUS = 'Shipped') as och,
				order_items
			WHERE
				order_items.ORDER_ID = och.ORDER_ID) as opq,
			product
		WHERE
			opq.PRODUCT_ID = product.PRODUCT_ID
		GROUP BY product.PRODUCT_CLASS_CODE
		ORDER BY product.PRODUCT_CLASS_CODE) as ft,
		product_class
	WHERE product_class.PRODUCT_CLASS_CODE = ft.PRODUCT_CLASS_CODE);
--------------
