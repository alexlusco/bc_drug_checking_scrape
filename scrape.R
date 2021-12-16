library(RSelenium)
library(rvest)
library(tidyverse)

driver <- rsDriver(browser=c("firefox"), port= 4833L)
remote_driver <- driver[["client"]]
remote_driver$open()

url <- "https://bccsudrugsense.herokuapp.com/?s=09"

remote_driver$navigate(url)

max_page <- remote_driver$findElement(using = "css", value = ".last-page")
max_page <- as.numeric(max_page$getElementText()[[1]]) - 1
pages <- 1:max_page

output <- list()

for (p in pages){
          table <- remote_driver$findElement(using = "xpath", value = "/html/body/div/div/div[3]/div/ul/li[3]/a")
          table$clickElement() 
          
          contents <- remote_driver$getPageSource()[[1]]
          
          contents <- read_html(contents)
          
          table_results <- contents %>%
            html_node("body") %>%
            html_nodes("table") %>%
            html_table()
          
          output[[p]] <- table_results
          
          table <- remote_driver$findElement(using = "css", value = ".next-page")
          table$clickElement() 
          
          Sys.sleep(3)
}

final_results <- output %>% bind_rows() %>% as_tibble()

write_csv(final_results, "final_results.csv")



