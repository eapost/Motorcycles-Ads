# Load libraries
library("jsonlite")
library("mongolite")
library("stringr")

# Data cleaning
CleanData <- function(x) {
  
  # Price cleaning
  if(x$ad_data$Price == 'Askforprice') {
    x$ad_data$Price <- NULL
    x$ad_data$AskForPrice <- TRUE
  }
  else {
    # Convert price to a number
    x$ad_data$Price <- as.numeric(gsub("[\200.]", "", x$ad_data$Price))
    x$ad_data$AskForPrice <- FALSE
    
    # If price is less than 10 euros, assume same as Askforprice
    if (x$ad_data$Price < 10) {
      x$ad_data$Price <- NULL
      x$ad_data$AskForPrice <- TRUE
    }
    
    # Find if a price is negotiable
    if(grepl( "Negotiable", x$metadata$model) == TRUE ) {
      x$metadata$Negotiable = TRUE
    }
    else {
      x$metadata$Negotiable = FALSE
    }
    
  }
  x$ad_data$Registration<-as.numeric(gsub(".*/", "",x$ad_data$Registration))
  z<-as.numeric(format(Sys.Date(), "%Y"))
  if(x$ad_data$Registration > 1910){
    x$ad_data$Ad_age<- z - x$ad_data$Registration
  }
  
  x$ad_data$Mileage<- as.numeric(gsub("[,km]", "", x$ad_data$Mileage))
  x$ad_data$`Make/Model`<-(gsub("'.*", "",  x$ad_data$`Make/Model`))
  return(x)
}

# Connection with mongodb
m <- mongo(collection = "mycol",  db = "mydb", url = "mongodb://localhost")
m$remove('{}')

# Upload text files
json <- read.table("files_list.txt", header = TRUE, sep="\n", stringsAsFactors = FALSE)

# Read all json files 
data <- c()
for (i in 1:nrow(json)) {
  x <- fromJSON(readLines(json[i,], warn=FALSE, encoding="UTF-8"))
  x <- CleanData(x)
  j <- toJSON(x, auto_unbox = TRUE)
  data <- c(data, j)
}

# Insert json objects in mongodb
m$insert(data)

# Question 2.2 - Τotal bikes for sale
m$count()

# Question 2.3 - Αverage number
m$aggregate('[{ "$match" : {"ad_data.Price" : { "$exists" : true } }}, {"$group":{"_id": null, "AvgPrice": {"$avg":"$ad_data.Price"}, "count": {"$sum" : 1 }}}]')

# Question 2.4 - Μin/max  price of a motorcycle 
m$aggregate(
'[
        { "$match" : 
            {"ad_data.Price" : 
             { "$exists" : true 
            } 
          }
        }, 
            {
        "$group":
        {"_id": null, "MinPrice": 
            {
              "$min":"$ad_data.Price"
            }, "MaxPrice": 
            {
              "$max":"$ad_data.Price"
        }
      }
   }
   ]'
)

# Question 2.5 - Bikes with price identified as negotiable

m$aggregate(
'[
        { "$match" : 
		   {"metadata.model": 
		       {"$regex" : "Negotiable", "$options" : "i"} 
			}
	    }, 
		{"$group":
		   {"_id": null,  "count": {"$sum" : 1 }
		     }
		}
]'
)

# Question 2.6 - Percentage of each brand that its listings is listed as negotiable

m$aggregate('
  [
    {
      "$group": {
        "_id": "$metadata.brand", 
        "TotalCount" : {"$sum" : 1 },
        "NegotiableCount" : {
          "$sum" : { "$cond": [{"$eq" : ["$metadata.Negotiable", true]}, 1, 0] }
        }
      }
    },
    {
      "$addFields": {
        "NegotiableRatio" : { 
          "$multiply" : [ {
            "$divide" : ["$NegotiableCount", "$TotalCount"] 
          }, 100] 
        }
      } 
    }
    ]'
)

# Question 2.7 - Μotorcycle brand with the highest average price

m$aggregate('
     [
        {
          "$group": 
              {"_id": "$metadata.brand", 
              "AvgPrice": {"$avg":"$ad_data.Price"}, 
              "count": {"$sum": 1}}},
        {
          "$sort": 
              {"AvgPrice": -1}
      },
            {
               "$limit": 1
       }
  ]')

# Question 2.8 - TOP 10 models with the highest average age

m$aggregate('
[
     {
      "$group": 
        {
          "_id": "$ad_data.Make/Model", 
          "AvgAge": {"$avg":"$ad_data.Ad_age"}, 
          "count": {"$sum": 1}
        }
     },
        {
          "$sort": 
          {
            "AvgAge": -1}
        },
          {
            "$limit": 10 
          }
]'
)

# Question 2.9 - Ηave “ABS” as an extra
m$count('{"extras" : "ABS"}')

# Question 2.10 - Average mileage of bikes that have “ABS” AND “Led lights” 

m$aggregate('
[
    { 
	  "$match" : 
	   {"extras" : "ABS", "extras": "Led lights" }
	}, 
	{"$group":
	  {"_id": null, "AvgMilage": {"$avg":"$ad_data.Mileage"}, 
	   "count": {"$sum" : 1 }
	  }
	}
]'
)

# Question 2.11 - TOP 3 colors per bike category

m$aggregate('
[
    {
     "$group": 
	  {
        "_id" : { "brand" : "$metadata.brand", "color": "$ad_data.Color" },
                         "ColorCount": {"$sum" : 1 }
      }
    },
    {
      "$sort": {"ColorCount": -1}
    },
    {
     "$group": 
        {
          "_id" : "$_id.brand",
          "colors" : {
          "$push" : {
          "color" : "$_id.color",
          "ColorCount" : "$ColorCount"
                    }
                     }
        }        
    },
    { 
     "$project": {
           "colors": { "$slice": [ "$colors", 3 ] }
                 }
    }
]'
)
