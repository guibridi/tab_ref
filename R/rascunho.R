library(stringr)

# Get the context of the page
thepage = readLines('https://tfm.sistemas.cesan.com.br/files/e-doc/')

# Find the lines that contain the names for netcdf files
pdf.lines <- grep('*.pdf', thepage)

# Subset the original dataset leaving only those lines
thepage <- thepage[pdf.lines]

#extract the file names
str.loc <- str_locate(thepage,'A.*pdf?"')

#substring
file.list <- substring(thepage,str.loc[,1], str.loc[,2]-1)

# download all files
for (ifile in file.list) {
  download.file(
    paste0(
      "https://data.giss.nasa.gov/impacts/agmipcf/agmerra/",
      ifile
    ),
    destfile = ifile,
    method = "libcurl"
  )

library(rvest)
library(xml2)
  url <- 'https://tfm.sistemas.cesan.com.br/files/e-doc/2019/01/'
  html <- rvest::read_html(url)

  cria_caminho <- function(url) {
    paste0(url,
           url |>
             rvest::read_html() |>
             rvest::html_nodes("a") |>
             rvest::html_attr("href") |>
             stringr::str_subset("^SERV.+pdf"))
  }

  cria_caminho(url)


tabela_cesan_2016_10 <- readr::read_rds("data-raw/CESAN/2017/02/2017_02.rds")

stringdist::stringdist(tabela_cesan_2016_10$descricao[8], tabela_cesan_2016_10$descricao[9])

texto <- text1

texto <- tm::Corpus(tm::VectorSource(texto))
texto <- texto |>
  tm::tm_map(tm::removePunctuation) |>
  tm::tm_map(tm::stripWhitespace)

texto <- tm::tm_map(texto, tm::content_transformer(tolower))
texto <- tm::tm_map(texto, tm::removeWords, tm::stopwords('portuguese'))
texto <- tm::scan_tokenizer(texto[["1"]][["content"]])

# STEP 1: Retrieving the data and uploading the packages
# To generate word clouds, you need to download the wordcloud package
# in R as well as the RcolorBrewer package for the colours. Note that
# there is also a wordcloud2 package, with a slightly different design
# and fun applications. I will show you how to use both packages.

# install.packages("wordcloud")
# install.packages("tm")
# install.packages("RColorBrewer")
# install.packages("wordcloud2")

library(wordcloud)
library(RColorBrewer)
library(wordcloud2)
library(tidyverse)
library(janitor)
library(tm)

# Most often, word clouds are used to analyse twitter data or a corpus of text.
# If you’re analysing twitter data, simply upload your data by using the rtweet
# package (see this article for more info on this). If you’re working on a speech,
# article or any other type of text, make sure to load your text data as a corpus.
# A useful way to do this is to use the tm package.

#Create a vector containing only the text


library(stringdist)
mysent = "This is a sentence"
apply(model_sentences, 1, function(row) {
  stringdist(row['model_text'], mysent, method="jaccard")
})


