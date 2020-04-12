# Load the library
library("redux")

# Local Connection
r <- redux::hiredis(
  redux::redis_config(
    host = "XXX", 
    port = "XXX"))

# Load datasets
modified_listings <- read.csv("modified_listings.csv", header = TRUE, sep=",", stringsAsFactors = FALSE)
emails_sent <- read.csv("emails_sent.csv", header = TRUE, sep=",", stringsAsFactors = FALSE)

# Question 1.1: Users modified their listing on January

for(i in 1:nrow(modified_listings))
{
  if ((modified_listings$ModifiedListing[i] ==1) & (modified_listings$MonthID[i]==1)) 
  {
    r$SETBIT("ModificationsJanuary",modified_listings$UserID[i],"1")
    
  }
}

r$BITCOUNT("ModificationsJanuary")

# Question 1.2: Users not modified their listing on January

r$BITOP("NOT","results1","ModificationsJanuary")
r$BITCOUNT("results1")

# Question 1.3: Users received at least one e-mail per month

for(i in 1:nrow(emails_sent))
{
  if (emails_sent$MonthID[i]==1)
  {
    r$SETBIT("EmailsJanuary",emails_sent$UserID[i],"1")
  }
  else if(emails_sent$MonthID[i]==2)
  {
    r$SETBIT("EmailsFebruary",emails_sent$UserID[i],"1")
    
  }
  else if (emails_sent$MonthID[i]==3)
  {
    r$SETBIT("EmailsMarch",emails_sent$UserID[i],"1")
    
  }
}
r$BITCOUNT("EmailsJanuary")

r$BITCOUNT("EmailsFebruary")

r$BITCOUNT("EmailsMarch")

r$BITOP("OR","results2",c("EmailsJanuary","EmailsFebruary" , "EmailsMarch"))

r$BITCOUNT("results2")

# Question 1.4: Users received e-mail only on January and March

r$BITOP("AND","results3",c("EmailsJanuary","EmailsMarch"))
r$BITCOUNT("results3")

r$BITOP("NOT", "results4", "EmailsFebruary")
r$BITCOUNT("results4")

r$BITOP("AND","combined result",c("results3","results4"))

r$BITCOUNT("combined result")

# Question 1.5: Users received e-mail on January which was not opened but their listing is updated

for(i in 1:nrow(emails_sent))
{
  if ((emails_sent$MonthID[i]==1) & (emails_sent$EmailOpened[i]==0))
  {
    r$SETBIT("January",emails_sent$UserID[i],"1")
  }
}

r$BITCOUNT("January")

r$BITOP("AND","EmailsOpenedJanuary",c("ModificationsJanuary","January"))

r$BITCOUNT("EmailsOpenedJanuary")

# Question 1.6: Users received e-mail which was not opened but their listing is updated (on Janury or February or March)

for(i in 1:nrow(modified_listings))
{
  if ((modified_listings$ModifiedListing[i] ==1) & (modified_listings$MonthID[i]==2)) 
  {
    r$SETBIT("ModificationsFebruary",modified_listings$UserID[i],"1")
    
  }
  else if ((modified_listings$ModifiedListing[i] ==1) & (modified_listings$MonthID[i]==3)) {
    r$SETBIT("ModificationsMarch",modified_listings$UserID[i],"1")
  }
}

for(i in 1:nrow(emails_sent))
{
  if ((emails_sent$MonthID[i]==2) & (emails_sent$EmailOpened[i]==0))
  {
    r$SETBIT("February",emails_sent$UserID[i],"1")
  }
  else if ((emails_sent$MonthID[i]==3) & (emails_sent$EmailOpened[i]==0))
  {
    r$SETBIT("March",emails_sent$UserID[i],"1")
  }
}

r$BITOP("AND","EmailsOpenedFebruary",c("ModificationsFebruary","February"))

r$BITOP("AND","EmailsOpenedMarch",c("ModificationsMarch","March"))

r$BITOP("OR","EmailsOpened",c("EmailsOpenedJanuary","EmailsOpenedFebruary","EmailsOpenedMarch"))
r$BITCOUNT("EmailsOpened")

# Question 1.7: Verify the effectiveness of the e-mail recommendation approach

# Inner join of 2 csv files
df<-merge(x=emails_sent, y=modified_listings, by=c("UserID","MonthID"))

# E-mails opened per month with the listing to be modified
for(i in 1:nrow(df))
{
  if ((df$EmailOpened[i]==1) & (df$ModifiedListing[i] ==1)) {
    if (df$MonthID[i]==1) {
      r$SETBIT("EmailsOpenedModifiedJanuary",df$UserID[i],"1")
    } else if (df$MonthID[i]==2) {
      r$SETBIT("EmailsOpenedModifiedFebruary",df$UserID[i],"1")
    } else {
      r$SETBIT("EmailsOpenedModifiedMarch",df$UserID[i],"1")
    }
  }
}

# E-mails opened per month without the listing to be modified
for(i in 1:nrow(df))
{
  if ((df$EmailOpened[i]==1) & (df$ModifiedListing[i] ==0)) {
    if (df$MonthID[i]==1) {
      r$SETBIT("EmailsOpenedNotModifiedJanuary",df$UserID[i],"1")
    } else if (df$MonthID[i]==2) {
      r$SETBIT("EmailsOpenedNotModifiedFebruary",df$UserID[i],"1")
    } else {
      r$SETBIT("EmailsOpenedNotModifiedMarch",df$UserID[i],"1")
    }
  }
}

r$BITCOUNT("EmailsOpenedModifiedJanuary")
r$BITCOUNT("EmailsOpenedNotModifiedJanuary")
# Percentage of modified listings for January
JanuaryPerc <- r$BITCOUNT("EmailsOpenedModifiedJanuary") /(r$BITCOUNT("EmailsOpenedModifiedJanuary")+r$BITCOUNT("EmailsOpenedNotModifiedJanuary")) * 100

r$BITCOUNT("EmailsOpenedModifiedFebruary")
r$BITCOUNT("EmailsOpenedNotModifiedFebruary")
# Percentage of modified listings for February
FebruaryPerc <- (r$BITCOUNT("EmailsOpenedModifiedFebruary") / (r$BITCOUNT("EmailsOpenedModifiedFebruary") + r$BITCOUNT("EmailsOpenedNotModifiedFebruary"))) * 100

r$BITCOUNT("EmailsOpenedModifiedMarch")
r$BITCOUNT("EmailsOpenedNotModifiedMarch")
# Percentage of modified listings for March
MarchPerc <- (r$BITCOUNT("EmailsOpenedModifiedMarch") / (r$BITCOUNT("EmailsOpenedModifiedMarch") + r$BITCOUNT("EmailsOpenedNotModifiedMarch"))) * 100
