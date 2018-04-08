/* ===============================================================================
 * Determine order count of 'tablet' during ad campaign month (May) and prev 3 months
 *================================================================================*/

 allorders = LOAD 'orders' AS (order_id:int,
              cust_id:int,
              order_dtm:chararray);

/* Include orders for 4 months */
months_order = FILTER orders BY order_dtm MATCHES '^2013-0[2345]-.*$';

/* Load the order_details information */
order_details = LOAD '/etl/order_details' AS (order_id:int,
             prod_id:int);

/* Filter data for just the product */
tablet_order = FILTER order_details BY prod_id == 1274348;

/* Join the order and order details data for 4 months */
tablet_order_details = JOIN months_order BY order_id,
                            tablet_order BY order_id;

/* Create a new relation containing just the month to aggregate in next step */
months = FOREACH tablet_order_details GENERATE SUBSTRING(order_dtm,1,7) as month;

/* Group by month and then count the records in each group */
grouped = GROUP months BY month;
counts = FOREACH grouped GENERATE group AS month, COUNT(months.month) as count;

-- TODO (D): Display the results to the screen
tablet_order_count = ORDER counts BY month;
DUMP tablet_order_count;
