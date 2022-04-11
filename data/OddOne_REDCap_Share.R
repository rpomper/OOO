

library("tidyjson")
library("jsonlite")
library("ggplot2")
library("tidyr")

# set your WD to the folder containing the exported REDCap data
# setwd("//boystown.org/btnrh/WordLearnLab/PreExp/Data") 
setwd("~/Documents/GitHub/OOO/data") 
d.json = read.csv("OOO_DATA_LABELS_2022-04-11_0857.csv",stringsAsFactors = F)

# option 1 - manually adjust incorrectly entered subject numbers
# excludeRecords = c(1,6,7)
# d.json = d.json %>% filter(!(Record.ID %in% excludeRecords))
# d.json$Subject.Number[d.json$Record.ID == 12] = 206 

# d.json = d.json %>% filter(!(is.na(Sub.Num.Adj))
# option 2 - merge with csv file with adjusted subject numbers
# d.info = read.csv("OddOneOut_SUB_INFO_2022-3-17.csv",stringsAsFactors=F)
# d.json = left_join(d.json,d.info))



# odd one trials ----------------------------------------------------------

# for each record
for(i in 1:length(d.json$Record.ID)) {
  # convert trials identifying the odd one out from JSON to data frame
  temp = fromJSON(as.character(d.json$Results.Images[i])) %>% 
    filter(condition != 'practice') %>%  # remove practice trials
    mutate(
      Phase = "Identify",
      Record.ID = d.json$Record.ID[i],
      Condition = as.integer(condition),
      Accuracy = ifelse(correct,1,0)) %>% 
    rename(Sub.Num = subject,
           Tr.Num = tr_num,
           Tr.Num.Overall = trial_index,
           Target=correct_response,
           Response=button_pressed,
           RT=rt)
  # convert the date of test information from one column in JSON format to two columns in character format
  date = fromJSON(as.character(d.json$Date.of.Test[i]))
  temp$Date = paste(as.character(date$month),"/",
                    as.character(date$day),"/",
                    as.character(date$year),sep="")
  temp$Time = paste(as.character(date$hour),":",as.character(date$min),sep="")
  # select the desired columns and put them in logical order
  temp = temp %>% select(Record.ID,Sub.Num,Date,Time,Phase,Tr.Num.Overall,Tr.Num,Condition,Response,RT,Accuracy)

  # concatenate with the previously edited records to make a single dataframe
  if(i==1){d = temp} else {d = rbind(d,temp)}
  
}

## let's take a peak at our data

# first let's calculate the average accuracy for each participant (Sub.Num) at each item-length (Condition)
d.sub = d %>% 
  group_by(Sub.Num,Condition) %>%
  summarise(
    n = length(Accuracy),
    Correct = sum(Accuracy),
    Accuracy = mean(Accuracy)
  )

# convert condition from a string to a factor for plotting purposes
d.sub$Condition = as.factor(as.character(d.sub$Condition))

# next let's calculate the average accuracy across participants at each item-length (Condition)
d.group = d.sub %>% 
  group_by(Condition) %>% 
  summarise(
    N=length(Accuracy),
    SD=sd(Accuracy),
    SE = SD/sqrt(N),
    min = min(Accuracy),
    max = max(Accuracy),
    Accuracy = mean(Accuracy),
    upper=Accuracy+SE,
    lower=Accuracy-SE
  )

# make a violin plot showing the average accuracy and distribution across participants at each item-length (Condition)
ggplot(d.group,aes(x=Condition,y=Accuracy)) +
  geom_violin(data=d.sub,alpha=.8)+
  geom_point(shape=16,fill='black',colour='black',size=2)+
  geom_errorbar(width=.2, aes(ymin=lower, ymax=upper)) +
  theme_bw(base_size=14) +
  coord_cartesian(ylim=c(-.01,1.01),xlim=c(.5,6.5),expand=F) +
  scale_y_continuous(breaks=seq(from=0,to=1,by=.1)) +
  labs(x='Item Length',y='% correct',title='Odd one out identification') +
  theme(legend.position='none',plot.title = element_text (hjust = 0.5)) 


# span trials -------------------------------------------------------------


# for each record
for(i in 1:length(d.json$Record.ID)) {
  # convert trials recalling the locations of each odd one out in the sequence from JSON to data frame
  temp = fromJSON(d.json$Results.Span[i]) %>% 
    filter(condition != 'practice') %>% 
    mutate(
           Phase = "Recall",
           Record.ID = d.json$Record.ID[i],
           Condition = as.integer(condition),
           Accuracy = ifelse(all_correct,1,0)) %>% 
    rename(Sub.Num=subject,
           Tr.Num=tr_num, 
           Tr.Num.Overall=trial_index,
           ResponseList = span_acc,
           RT=rt)
  # convert the date of test information from one column in JSON format to two columns in character format
  date = fromJSON(as.character(d.json$Date.of.Test[i]))
  temp$Date = paste(as.character(date$month),"/",
                    as.character(date$day),"/",
                    as.character(date$year),sep="")
  temp$Time = paste(as.character(date$hour),":",as.character(date$min),sep="")
  # select the desired columns and put them in logical order
  temp = temp %>% select(Record.ID,Sub.Num,Date,Time,Phase,Tr.Num.Overall,Tr.Num,Condition,ResponseList,RT,Accuracy)
    
  # concatenate with the previously edited records to make a single dataframe
  if(i==1){s = temp} else {s = rbind(s,temp)}
  
}

# for recall trials, children are recalling the location of X number of odd one out shapes from the X-item sequence
# in creating the dataframe, R chose a list format, which has some advantages
# but we need to convert Response (a list) into a string (separating each element in the list by a ,)
# this is necessary for exporting the data into a csv file

temp = s %>% 
  # separate each Response into multiple rows (one row per item in the list)
  unnest(ResponseList) %>% 
  group_by(Record.ID,Tr.Num.Overall) %>% 
  # then collapse these back into a single row again by combining them all into a string
  summarise(Response = toString(ResponseList))

s = left_join(s,temp) %>% select(-ResponseList)


## we can take a peak at our data again using the same aggregating as before

s.sub = s %>% 
  group_by(Sub.Num,Condition) %>%
  summarise(
    n = length(Accuracy),
    Correct = sum(Accuracy),
    Accuracy = mean(Accuracy)
  )

s.sub$Condition = as.factor(as.character(s.sub$Condition))

s.group = s.sub %>% 
  group_by(Condition) %>% 
  summarise(
    N=length(Correct),
    SD=sd(Correct),
    SE = SD/sqrt(N),
    min = min(Correct),
    max = max(Correct),
    Correct = mean(Correct),
    upper=Correct+SE,
    lower=Correct-SE
  )



ggplot(s.group,aes(x=Condition,y=Correct)) +
  geom_violin(data=s.sub,alpha=.8)+
  geom_point(shape=16,fill='black',colour='black',size=2)+
  geom_errorbar(width=.2, aes(ymin=lower, ymax=upper)) +
  theme_bw(base_size=14) +
  coord_cartesian(ylim=c(-.01,4.01),xlim=c(.5,6.5),expand=F) +
  scale_y_continuous(breaks=seq(from=1,to=4,by=1)) +
  labs(x='Item Length',y='# trials correct (4 max)',title='Odd one out memory') +
  scale_fill_manual(values=c('coral2','dodgerblue','forestgreen'))+
  theme(legend.position='none',plot.title = element_text (hjust = 0.5))



# max span ----------------------------------------------------------------

# in our analyses though we only care about one of two outcome variables

# first, the total number of span trials children had correct
# recall there's a maximum of 24: 4 per condition with 6 conditions (item lengths 1, 2, 3, 4, 5, 6)
# recall also that each trial is correct *only* if the child correctly recalled the location of the odd one out for every item in the list

# second, is the maximum span the child reached before administration stopped
# this will be one of the 6 conditions (item length 1, 2, 3, 4, 5, or 6)
# recall that administration stops if the child is incorrect on 2 or more of the 4 trials in a condition (i.e., # correct < 3)

m.sub = s %>% 
  group_by(Record.ID,Sub.Num,Date,Time) %>% 
  summarise(
    Total.Correct = sum(Accuracy),
    Max.Span = max(as.integer(as.character(Condition)))) %>% 
  arrange(Sub.Num)


m.group = m.sub %>% 
  group_by() %>% 
  summarise(
    N=length(Max.Span),
    SD=sd(Max.Span),
    SE = SD/sqrt(N),
    min = min(Max.Span),
    max = max(Max.Span),
    Max.Span = mean(Max.Span),
    upper=Max.Span+SE,
    lower=Max.Span-SE
  )


ggplot(m.group,aes(x="",y=Max.Span)) +
  geom_violin(data=m.sub,alpha=.8)+
  geom_point(shape=16,fill='black',colour='black',size=2)+
  geom_errorbar(width=.2, aes(ymin=lower, ymax=upper)) +
  theme_bw(base_size=14) +
  coord_cartesian(ylim=c(-.01,6.01),xlim=c(.5,1.5),expand=F) +
  scale_y_continuous(breaks=seq(from=1,to=6,by=1)) +
  labs(x='Group',y='max span',title='Odd one out span') +
  theme(legend.position='none',plot.title = element_text (hjust = 0.5))



# export ------------------------------------------------------------------

combined = bind_rows(d,s) %>% arrange(Sub.Num,Tr.Num.Overall)

write.csv(combined,paste("OddOneOut_Data_ByTrial_n",n_distinct(combined$Sub.Num),".csv",sep=""))
write.csv(m.sub,paste("OddOneOut_Data_Span_n",n_distinct(m.sub$Sub.Num),".csv",sep=""))
        