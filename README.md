# MotorcyclesAds

You are going to use REDIS and MongoDB to perform an analysis on data related to classified ads from the used motorcycles market.

1.	Install REDIS and MongoDB on your workstations. Version 4 of REDIS for windows is available here: https://github.com/tporadowski/redis/releases. If you have an older version, make sure that you upgrade since some of the commands needed for the assignment are not supported by older versions. The installation process is straightforward.
2.	Download the BIKES_DATASET.zip dataset. 
3.	Download the RECORDED_ACTIONS.zip dataset.
4.	Do the tasks listed in the “TASKS” section: 

# SCENARIO

You are a data analyst at a consulting firm and you have access to a dataset of ~30K classified ads from the used motorcycles market. You also have access to some seller related actions that have been tracked in the previous months. You are asked to create a number of programs/queries for the tasks listed in the “TASKS” section.


# ASSIGNMENT NOTES

-	You may work on any programming language of your choice. Code samples are provided in R but the choice of language is up to you. 
-	The dataset is in JSON format. It needs cleaning. You don’t need to follow the guidelines provided below. You may do the cleaning any way you like.
-	In your deliverable, you should include (along with your code) a report justifying the steps you took in order to perform the tasks. The report should be VERY brief.
-	ONE deliverable per team. The names of the members of each team along with their AM should be included in the first page of the report.
-	Your code should be fully commented.

# TASKS

[Task 1]

In this task you are going to use the “recorded actions” dataset in order to generate some analytics with REDIS.

At the end of each month, the classifieds provider sends a personalized e-mail to some of the sellers with a number of suggestions on how they could improve their listings. Some e-mails may have been sent two or three times in the same month due to a technical issue. Not all users open these e-mails. However, we keep track of the e-mails that have been read by their recipients. Apart from that you are also given access to a dataset containing all the user ids along with a flag on whether they performed at least one modification on their listing for each month.

In brief, the datasets are the following:
-	emails_sent.csv “Sets of EmailID, UserID, MonthID and EmailOpened”
-	modified_listings.csv “Sets of UserID, MonthID, ModifiedListing”

The first dataset contains User IDs that have received an e-mail at least once. The second dataset contains all the User IDs of the classifieds provider and a flag that indicates whether the user performed a modification on his/her listing. Both datasets contain entries for the months January, February and March.

You are asked to answer a number of questions using REDIS Bitmaps. A Bitmap is the data structure that immediately pops in your head when the need is to map Boolean information for a huge domain into a compact representation. REDIS, being an in-memory data structure server, provides support for bit manipulation operations. However, there isn’t a special data structure for Bitmaps in REDIS. Rather, bit level operations are supported on the basic REDIS structure: Strings. Now, the maximum length for REDIS strings is 512 MB. Thus, the largest domain that REDIS can map as a Bitmap is 2^32 (512 MB = 2^29 bytes = 2^32 bits).

General Note: Some users may have received more than one e-mail in the same month. If a client opened at least one of the e-mails that she/he received in the same month then we will classify this client as having opened this month’s newsletter.

# Provide answers for the following questions:

1. How many users modified their listing on January? 
Tip: Create a BITMAP called “ModificationsJanuary” and use “SETBIT -> 1” for each user that modified their listing. Use BITCOUNT to calculate the answer.
2. How many users did NOT modify their listing on January?
Tip: Use “BITOP NOT” to perform inversion on the “ModificationsJanuary” BITMAP and use BITCOUNT to calculate the answer. Combine the results with the answer of 1.1. Do these numbers match the total of your users? Even if they don’t, an explanation of why this happens will give you the full grade. Keep in mind that all BITOP operations happen at byte-level increments.
3. How many users received at least one e-mail per month (at least one e-mail in January and at least one e-mail in February and at least one e-mail in March)?
4. How many users received an e-mail on January and March but NOT on February?
5. How many users received an e-mail on January that they did not open but they updated their listing anyway?
6. How many users received an e-mail on January that they did not open but they updated their listing anyway on January OR they received an e-mail on February that they did not open but they updated their listing anyway on February OR they received an e-mail on March that they did not open but they updated their listing anyway on March?
7. Does it make any sense to keep sending e-mails with recommendations to sellers? Does this strategy really work? How would you describe this in terms a business person would understand?
8. (Optional Task) Do the previous subtasks again by using any type of relational or non-relational database. Compare the complexity of the solutions. Then benchmark the query execution time for the dataset that you have. At last, boost the number of entries to 1 billion rows (create your own dummy entries). Perform the benchmark again.

[Task 2]

In this task you are going to use the “bikes” dataset in order to generate some analytics with MongoDB.

1. Add your data to MongoDB.
2. How many bikes are there for sale?
3. What is the average price of a motorcycle (give a number)? What is the number of listings that were used in order to calculate this average (give a number as well)? Is the number of listings used the same as the answer in 1.2? Why?
4. What is the maximum and minimum price of a motorcycle currently available in the market?
5. How many listings have a price that is identified as negotiable? Tip: Search for the word “Negotiable” in the ad.
6. For each Brand, what percentage of its listings is listed as negotiable?
7. What is the motorcycle brand with the highest average price?
8. What are the TOP 10 models with the highest average age? (Round age by one decimal number)
9. How many bikes have “ABS” as an extra? 
10. What is the average Mileage of bikes that have “ABS” AND “Led lights” as an extra?
11. What are the TOP 3 colors per bike category?
12.	Identify a set of ads that you consider “Best Deals”. 
