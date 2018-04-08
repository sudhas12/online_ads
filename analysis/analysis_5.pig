/*======================================================================
 Classify customers based on their buying habits:
        1. Number of orders placed >= 5
        2. Cost of orders placed
========================================================================*/
/* load the data sets */
orders = LOAD 'orders' AS (order_id:int,
                           cust_id:int,
                           order_dtm:chararray);

details = LOAD 'order_details' AS (order_id:int,
                                   prod_id:int);

products = LOAD 'products' AS (prod_id:int,
                               brand:chararray,
                               name:chararray,
                               price:int,
                               cost:int,
                               shipping_wt:int);

/* Include only records from 2012 */
orders_2012 = FILTER orders BY SUBSTRING(order_dtm,1,4) MATCHES '^2012-.*$'

/* group by customers and select customers who have at least 5 orders */
grouped = GROUP orders_2012 BY cust_id;
custid2012 = FOREACH grouped GENERATE
                            group as cust_id,
                            orders_2012.order_id as order_id,
                            COUNT(orders_2012.cust_id) as num_orders;

q_customers = FILTER custid2012 BY num_orders >=5;

flat = FOREACH q_customers GENERATE
             cust_id,
             FLATTEN(order_id) AS order_id;

/* Join these order records with details about the order so
 * we'll know which products were purchased, and then join
 * that with product info so we can calculate total price  */

order_info = JOIN flat BY order_id,
                 details BY order_id;

all_info = JOIN order_info BY prod_id,
                products BY prod_id;

/* Simplify the complex data structure by creating a new
* relation containing only the two fields we need */
cust_prods = FOREACH all_info GENERATE
                    flat::cust_id AS cust_id,
                    products::price AS price;

/* calculate total sales for each of these customers */
orders_by_cust = GROUP cust_prods BY cust_id;
totals_by_cust = FOREACH orders_by_cust GENERATE
                      group AS cust_id,
                      SUM(cust_prods.price) AS total;

/* split them into groups based on total sales */
SPLIT totals_by_cust INTO platinum IF total >= 1000000,
                          gold IF (total >= 500000 AND total < 1000000),
                          silver IF (total >= 250000 AND total < 500000);

/* store these groups to directories in HDFS */
store platinum INTO '/platinum';
store gold INTO '/gold';
store silver INTO '/silver';
