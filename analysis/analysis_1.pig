/*======================================================================
 * Script is aimed at optimizing cost of campaign ads to attract more customers
 * and reduce ad cost by:
 *          a. Determine lowest cost display site
 *          b. Display highest cost keywords
 *          c. Total number of ad clicks
 *          d. Worst case cost for 30K clicks
 *          e. Click thro rate (CTR)
 *======================================================================*/

  /* Load the data */
   data = LOAD '/etl/addata[12]/'
          AS
               (campaign_id:chararray,
                date:chararray, time:chararray,
                keyword:chararray, display_site:chararray,
                placement:chararray, was_clicked:int, cpc:int);

 /* Include only records which indicates user was_clicked the ad */
    clicked = FILTER data BY was_clicked == 1;

/* ======================================================================
 * Determine lowest cost display site
 * =====================================================================*/

/* Group the data by the display_site
  group_display_site = GROUP clicked BY display_site;

 /* Create a new DS which includes only the display site
  * and the total cost of all clicks on that site
  */
  display_site_cost = FOREACH group_display_site
                      GENERATE group AS
                               display_site, SUM(clicked.cpc) AS cost;

/* Sort that new relation by cost */
  sortedcost = ORDER display_site_cost BY cost in ascending order;

/*Display first 5 records
  top5 = LIMIT  sortedcost 5;  -- asecending is default
  DUMP top5;

/* ======================================================================
 * Determine highest cost keyword
 * =====================================================================*/

  /* Include only records which indicates user was_clicked the ad */
     clicked = FILTER data BY was_clicked == 1;

 /* Group the data by keyword
   group_keyword = GROUP clicked BY keyword;

  /* Create a new DS which includes only the keyword
   * and the total cost of all clicks on that site
   */
   keyword_cost = FOREACH group_keyword
                       GENERATE group AS
                                keyword, SUM(clicked.cpc) AS cost;

 /* Sort that new relation by cost in descending order  */
   sortedcost_keyword = ORDER keyword_cost BY cost DESCENDING;

 /*Display first 5 records  */
   top5 = LIMIT  sortedcost_keyword 5;
   DUMP top5;

 /* ======================================================================
  * Determine total number of clicks across records
  * =====================================================================*/

/* Group All records to be able to call aggregate function */
   all_grouped = GROUP clicked ALL;

/* Count the records */
   total_clicks = FOREACH all_grouped GENERATE COUNT(clicked.cpc);

 /* Display the result to the screen */
   DUMP total_clicks;

 /* ======================================================================
  * Worst case cost for 100,000 clicks
  * =====================================================================*/

/* Group all data */
grouped = GROUP data  BY ALL;

/* calculate worst case max cost for 100K by selecting max cost cpc and multiplying by 100K*/
maxcost = FOREACH grouped GENERATE MAX(data.cpc) * 30000 as max_cost;

/* Display the result to the screen */
DUMP maxcost;

/* ======================================================================
 * Calculate lowest click thro rate.
 * =====================================================================*/
/* group data by display_site
grouped = GROUP data BY display_site;

by_site = FOREACH grouped {
-- Include only records where the ad was clicked
  clicked = FILTER data BY was_clicked == 1;

-- Count the number of records total in group
  total = COUNT(data.display_site);

-- count the number of records clicked this group
  clickcount = COUNT(clicked.was_clicked);

  /* Calculate the click-through rate by dividing the
   * clicked ads in this group by the total number of ads
   * in this group.
   */
  GENERATE group, (double) clickcount/total as ctr;
}
/* sort the records in ascending order of click through rate (CTR)*/
sorted = ORDER by_site BY ctr;

/* show just the first three */
top3 = LIMIT sorted 3;
