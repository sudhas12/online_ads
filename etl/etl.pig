/* ==================================================================
   Script takes two types of input files from different advertising
   companies, cleans the file,extracts the required data and formats
   and writes to two HDFS folders. The contents of the two files will
   be used for further analysis.
   ================================================================*/
/* ================================================================
  ETL of data file 1
  ================================================================*/

/* Load data file1 and define the structure of the data */
   data1 = LOAD 'addata1.txt'
          USING PigStorage('\t')  -- tab delimited is default.
          AS (
                 keyword:chararray,
                 campaign_id:chararray,
                 date:chararray,
                 time: chararray,
                 display_site:chararray,
                 was_clicked:int,
                 cpc:int,
                 country:chararray,
                 placement:chararray);

/* check the schema of the data to make sure it matches definition above */
 DESCRIBE data1;

/* Remove duplicate data */
data1_distinct = DISTINCT data1;

/* filter the data for one country */
 data1_usa= FILTER data1_distinct BY (country == 'USA');

 /* reformat each line of data as follows:
       a. reorder the fields,
       b. trim spaces in keyword
       c. Convert the keyword to uppercase
  */
data1_reordered= FOREACH  data1_usa
            GENERATE
                 campaign_id,
                 date,
                 time,
                 UPPER(TRIM(keyword)),
                 display_site,
                 placement,
                 was_clicked,
                 cpc;

/* Store the reordered data into HDFS file */
STORE data1_reordered
INTO  '/etl/addata1/'
USING PigStorage('\t') ;  -- tab delimited is default and is not really rqd here

/* ==================================================================
  ETL of DATA FILE #2
  ===================================================================*/

/* Load data file 2 and define the structure of the data */
data2 = LOAD '/etl/addata2.txt'
        USING PigStorage(',') -- comma separated is NOT default and has to be included
        AS (
             campaign_id: chararray,
             date: chararray,
             time: chararray,
             display_site: chararray,
             placement: chararray,
             was_clicked: int,
             cpc: int,
             keyword: chararray) ;

/* Remove duplicate duplicate data */
data2_distinct = DISTINCT data2;

/* filter the data for one country */
 data2_usa= FILTER data2_distinct BY (country == 'USA');

 /* reformat each line of data as follows:
       a. reorder the fields,
       b. trim spaces in keyword
       c. Convert the keyword to uppercase
       d. Replace the time format from 'mm-dd-yyyy' to 'mm/dd/yyyy'
 */
data2_reordered = FOREACH data2_distinct
            GENERATE
               campaign_id,
               REPLACE(date,'-','/'),
               time,
               UPPER(TRIM(keyword)),
               display_site,
               placement,
               was_clicked,
               cpc) ;

STORE data2_reordered INTO '/dualcore/ad_data2/';
