
/*==========================================================================
 * Display order count for the ad campaign month(May) and previous 3 months
 * ========================================================================*/
data = LOAD 'orders' AS (order_id:int,
             cust_id:int,
             order_dtm:chararray);
/* Include only records where the 'order_dtm' field matches
 * year and months feb-may using regular expression pattern:
 *
 *   ^       = beginning of string
 *   2013    = literal value '2013'
 *   0[2345] = 0 followed by 2, 3, 4, or 5
 *   -       = a literal character '-'
 *   \\d{2}  = exactly two digits
 *   \\s     = a single whitespace character
 *   .*      = any number of any characters
 *   $       = end of string
 *
  */
recent4months = FILTER data BY order_dtm MATCHES '^2013-0[2345]-\\d{2}\\s.*$';

/* Create a new relation with just the order's year and month */
months = FOREACH recent4months GENERATE SUBSTRING(order_dtm,1,7) as month;

/* group the number of orders in each month */
groupbymonth  = GROUP months BY  month;

/* Count the number of orders by month */
ordercount = FOREACH groupbymonth GENERATE
                    group as month,
                    COUNT(months.month) as count;

/* Display the count by month to the screen. */
DUMP ordercount;
