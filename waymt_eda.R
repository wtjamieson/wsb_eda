library(tidyverse)
library(tidytext)
library(lubridate)
library(anytime)

#Read in comments
#waymt <- (readr::read_csv("waymt_4_23_21.csv") %>%
#  mutate(created_utc = anytime(created_utc)) %>%
#  filter(created_utc <= as_datetime("2021-04-23 9:00:00 EDT"))) %>%
#  rbind((readr::read_csv("waymt_4_26_21.csv") %>%
#           mutate(created_utc = anytime(created_utc)) %>%
#           filter(created_utc <= as_datetime("2021-04-26 9:00:00 EDT"))) ) %>%
#  rbind((readr::read_csv("waymt_4_27_21.csv") %>%
#     mutate(created_utc = anytime(created_utc)) %>%
#     filter(created_utc <= as_datetime("2021-04-27 9:00:00 EDT"))) ) %>%
#  rbind((readr::read_csv("waymt_4_28_21.csv") %>%
#           mutate(created_utc = anytime(created_utc)) %>%
#           filter(created_utc <= as_datetime("2021-04-28 9:00:00 EDT"))) ) %>%
#  rbind((readr::read_csv("waymt_4_29_21.csv") %>%
#           mutate(created_utc = anytime(created_utc)) %>%
#           filter(created_utc <= as_datetime("2021-04-29 9:00:00 EDT"))) )  %>%
#  rbind((readr::read_csv("waymt_4_30_21.csv") %>%
#           mutate(created_utc = anytime(created_utc)) %>%
#           filter(created_utc <= as_datetime("2021-04-30 9:00:00 EDT"))) )  %>%
#  rbind((readr::read_csv("waymt_5_03_21.csv") %>%
#           mutate(created_utc = anytime(created_utc)) %>%
#           filter(created_utc <= as_datetime("2021-05-03 9:00:00 EDT"))) )  %>%
#  rbind((readr::read_csv("waymt_5_04_21.csv") %>%
#           mutate(created_utc = anytime(created_utc)) %>%
#           filter(created_utc <= as_datetime("2021-05-04 9:00:00 EDT"))) )

#waymt <- waymt %>%
#  mutate(date = date(created_utc),
#         date = if_else(wday(date) == 6, date + days(2), date),
#         date = if_else(wday(date) == 7, date + days(1), date),
#         date = if_else(wday(date) %in% c(1,2,3,4,5),date + days(1), date)
#         )

#write.csv(waymt,"all_waymt.csv", row.names = FALSE)
waymt <- readr::read_csv("all_waymt.csv")

#Filter by comments that are made before the market opens
#waymt <- waymt %>%
#  mutate(created_utc = anytime(created_utc)) %>%
#  filter(created_utc <= as_datetime("2021-04-23 9:00:00 EDT"))

#Read in stock information 
stocks <- readr::read_csv("stock_prices.csv")


#Get dataframe of dictionary words
dictionary <- readr::read_csv("dictionary.csv")

#Separate out the words in the comment texts
tidy_waymt <- waymt %>%
  unnest_tokens(word,body)

tidy_waymt %>%
  filter(toupper(word) %in% symbols_list,
         tolower(word) %notin% (dictionary %>% 
                               anti_join(as.data.frame(list(word = c("coin","gt","riot","coke","ford"))), by = "word"))$word,
         tolower(word) %notin% as.data.frame(list(word = c("has","lmao","kids","vs","jobs","eyes")))$word) %>%
  distinct() %>%
  group_by(word,date) %>%
  mutate(n = n(),
         avg_score = mean(score)) %>%
  ungroup() %>%
  left_join((stocks %>% select(date,symbol,per_gain)), by = c("word" = "symbol", "date" = "date")) %>%
  select(date,word,n,avg_score,per_gain) %>%
  distinct() %>%
  filter(n > 25) %>%
  ggplot(aes(avg_score,per_gain,size =n, color = as.factor(date))) + 
  geom_point(alpha = 0.8) +
  scale_y_continuous(labels = scales::percent) +
  labs(x = "Average Score of Comments Containing Stock", y = "Stock Price Gain Next Day", color = "Date", size = "Number of Comments", color = "Date") +
  ggtitle('"What Are Your Moves Tomorrow" Comments')

