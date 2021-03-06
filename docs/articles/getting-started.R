## ---- echo = FALSE-------------------------------------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = NOT_CRAN,
  eval = NOT_CRAN
)

## ----auth, include = FALSE-----------------------------------------------
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(here)))
library(salesforcer)
token_path <- here::here("tests", "testthat", "salesforcer_token.rds")
suppressMessages(sf_auth(token = token_path, verbose = FALSE))

## ----load-package, eval=FALSE--------------------------------------------
#  suppressWarnings(suppressMessages(library(dplyr)))
#  library(salesforcer)
#  sf_auth()

## ----other-params, eval=FALSE--------------------------------------------
#  options(salesforcer.consumer_key = "012345678901-99thisisatest99connected33app22key")
#  options(salesforcer.consumer_secret = "Th1s1sMyConsumerS3cr3t")
#  
#  sf_auth()

## ------------------------------------------------------------------------
# pull down information of person logged in
# it's a simple easy call to get started 
# and confirm a connection to the APIs
user_info <- sf_user_info()
sprintf("User Id: %s", user_info$id)
sprintf("User Active?: %s", user_info$isActive)

## ------------------------------------------------------------------------
n <- 2
new_contacts <- tibble(FirstName = rep("Test", n),
                       LastName = paste0("Contact-Create-", 1:n))
created_records <- sf_create(new_contacts, "Contact")
created_records

## ------------------------------------------------------------------------
retrieved_records <- sf_retrieve(ids=created_records$id, 
                                 fields=c("FirstName", "LastName"), 
                                 object_name="Contact")
retrieved_records

## ----query-records-------------------------------------------------------
my_soql <- sprintf("SELECT Id, 
                           Account.Name, 
                           FirstName, 
                           LastName 
                    FROM Contact 
                    WHERE Id in ('%s')", 
                   paste0(created_records$id , collapse="','"))

queried_records <- sf_query(my_soql)
queried_records

## ----update-records------------------------------------------------------
# Update some of those records
queried_records <- queried_records %>%
  mutate(FirstName = "TestTest") %>% 
  select(-Account)

updated_records <- sf_update(queried_records, object_name="Contact")
updated_records

## ------------------------------------------------------------------------
deleted_records <- sf_delete(updated_records$id)
deleted_records

## ------------------------------------------------------------------------
n <- 2
new_contacts <- tibble(FirstName = rep("Test", n),
                       LastName = paste0("Contact-Create-", 1:n), 
                       My_External_Id__c=letters[1:n])
created_records <- sf_create(new_contacts, "Contact")

upserted_contacts <- tibble(FirstName = rep("Test", n),
                            LastName = paste0("Contact-Upsert-", 1:n), 
                            My_External_Id__c=letters[1:n])
new_record <- tibble(FirstName = "Test",
                     LastName = paste0("Contact-Upsert-", n+1), 
                     My_External_Id__c=letters[n+1])
upserted_contacts <- bind_rows(upserted_contacts, new_record)

upserted_records <- sf_upsert(input_data=upserted_contacts, 
                              object_name="Contact", 
                              external_id_fieldname="My_External_Id__c")
upserted_records

## ---- include = FALSE----------------------------------------------------
deleted_records <- sf_delete(upserted_records$id)

