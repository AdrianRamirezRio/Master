# Data loading and preprocessing
load_businesses = function() {
  return(subset(read.csv("data/yelp_academic_dataset_business_200.csv", stringsAsFactors=FALSE), select=-c(X)))
}

# Data loading and preprocessing
load_reviews = function() {
  return(subset(read.csv("data/yelp_academic_dataset_reviews_200.csv", stringsAsFactors=FALSE), select=-c(X)))
}

# Filter functions
filterByPreference = function(data, preference) {
  if (is.null(preference)) {
    return(data)
  }
  if (preference == "breakfast") {
    data = data[data$Breakfast == "True",]
  }
  if (preference == "lunch") {
    data = data[data$Lunch == "True",]
  }
  if (preference == "dinner") {
    data = data[data$Dinner == "True",]
  }
  if (preference == "dessert") {
    data = data[data$Dessert == "True",]
  }
  return(data)
}

filterByCities = function(data, cities) {
  if (!is.null(cities)) {
    data = subset(data, City %in% cities)
  }
  return(data)
}

filterByTakeOut = function(data, takeout) {
  if (takeout==TRUE) {
    data = subset(data, TakeOut=="True")
  }
  return(data)
}

selectImage = function(n) {
  if (n < 0 || n > 5){
    print("Error: number of stars is not within the range")
  }

  imgURL = switch(as.character(n),
         "0" = "/5_Star_Rating_System_0_stars.png",
         "0.5" = "/5_Star_Rating_System_0_and_a_half_stars.png",
         "1" = "/5_Star_Rating_System_1_stars.png",
         "1.5" = "/5_Star_Rating_System_1_and_a_half_stars.png",
         "2" = "/5_Star_Rating_System_2_stars.png",
         "2.5" = "/5_Star_Rating_System_2_and_a_half_stars.png",
         "3" = "/5_Star_Rating_System_3_stars.png",
         "3.5" = "/5_Star_Rating_System_3_and_a_half_stars.png",
         "4" = "/5_Star_Rating_System_4_stars.png",
         "4.5" = "/5_Star_Rating_System_4_and_a_half_stars.png",
         "5" = "/5_Star_Rating_System_5_stars.png")

  return(as.character(img(src=imgURL, height = 15, width = 85)))
}

starsHTML = function(stars) {
  sapply(stars, selectImage)
}

addMarkersGroup = function(map, rest_data_group, group_id) {
  map %>% 
  addMarkers(data=rest_data_group, 
             clusterOptions=markerClusterOptions(),
             clusterId = "all",
             popup=paste("<b>", rest_data_group$Name,"</b><br>",
                         starsHTML(rest_data_group$Stars), "<br>",
                         gsub(", ", " <br/> ", rest_data_group$Address)
             ),
             group=group_id
  )
  
}