/*====================================================================================
 * Calculate the avg. number of items for all orders that contain the advertised tablet
 *======================================================================================*/
orders = LOAD 'orders' AS (order_id:int,
                           cust_id:int,
                          order_dtm:chararray);

details = LOAD 'order_details' AS (order_id:int,
                                  prod_id:int);

/* Include only records from the ad campaign month(May)  */
may_orders = FILTER orders BY order_dtm MATCHES '2013-05-.*$';

/* Find all the orders containing the advertised product */
tablet_orders = FILTER details BY prod_id == 1274348;

/* Combine order and order details for 'tablet'
joined_may = JOIN may_orders BY order_id,
              tablet_orders BY order_id;

/* Generate new relation with orderids to help with aggregation further down */
tablet_orders_may = FOREACH joined_may GENERATE may_orders::order_id as order_id;

/* Remove duplicates if any */
distinct_tablet_orders = DISTINCT tablet_orders_may;

/* Get the details for each of those orders */
tablet_order_details = JOIN distinct_tablet_orders BY order_id,
                            details BY order_id;

flat =FOREACH tablet_order_details GENERATE
                           distinct_tablet_orders::order_id as order_id,
                           details::prod_id as prod_id;

/* Count the number of items in each order */
grouped  = GROUP flat by order_id;
counted  = FOREACH grouped GENERATE group as order_id ,
                                    COUNT(orders1.order_id) as counts;

/*  Calculates the average number of items in each order */
groupall = GROUP counted ALL;
average = FOREACH groupall GENERATE AVG(counted.counts);

/* Display the final result to the screen */
DUMP average;



=================================================
- load the data sets
orders = LOAD '/dualcore/orders' AS (order_id:int,
             cust_id:int,
             order_dtm:chararray);

details = LOAD '/dualcore/order_details' AS (order_id:int,
             prod_id:int);

products = LOAD '/dualcore/products' AS (prod_id:int,
             brand:chararray,
             name:chararray,
             price:int,
             cost:int,
             shipping_wt:int);


             /*
              * TODO: Find all customers who had at least five orders
              *       during 2012. For each such customer, calculate
              *       the total price of all products he or she ordered
              *       during that year. Split those customers into three
              *       new groups based on the total amount:
              *
              *        platinum: At least $10,000
              *        gold:     At least $5,000 but less than $10,000
              *        silver:   At least $2,500 but less than $5,000
              *
              *       Write the customer ID and total price into a new
              *       directory in HDFS. After you run the script, use
              *       'hadoop fs -getmerge' to create a local text file
              *       containing the data for each of these three groups.
              *       Finally, use the 'head' or 'tail' commands to check
              *       a few records from your results, and then use the
              *       'wc -l' command to count the number of customers in
              *       each group.
              */
