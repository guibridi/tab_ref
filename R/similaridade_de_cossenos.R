tabela_cesan_raw <- readr::read_rds("data-raw/CESAN/2020/03/2020_03.rds")


text1 <- tabela_cesan_raw$descricao[17]

text2 <- tabela_cesan_raw$descricao[18]

stringdist::stringdist(text1, text2, method = "lc")

sim_cosseno <- function(text1, text2){

text1 <- stringr::str_replace_all(text1, pattern = "/", replacement = " ")

text1 <- iconv(text1, from = 'UTF-8', to = 'ASCII//TRANSLIT')

text2 <- stringr::str_replace_all(text2, pattern = "/", replacement = " ")

text2 <- iconv(text2, from = 'UTF-8', to = 'ASCII//TRANSLIT')

tokenizar <- function(texto) {
  texto <- tm::Corpus(tm::VectorSource(texto))
  texto <- texto |>
    tm::tm_map(tm::removePunctuation) |>
    tm::tm_map(tm::stripWhitespace)

  texto <- tm::tm_map(texto, tm::content_transformer(tolower))
  texto <-
    tm::tm_map(texto, tm::removeWords, tm::stopwords('portuguese'))

  tm::scan_tokenizer(texto[["1"]][["content"]])
}

l1 <- tokenizar(text1)
l2 <- tokenizar(text2)

vetor <- unique(c(l1 , l2))

vet1 <- c(NULL)
vet2 <- c(NULL)

for (w in vetor) {

  if (w %in% l1) {
    vet1 <- c(vet1, 1)
  }
  else{
    vet1 <- c(vet1, 0)
  }
  if (w %in% l2) {
    vet2 <- c(vet2, 1)
  }
  else{
    vet2 <- c(vet2, 0)
  }
}

c <- 0

for (i in 1:length(vetor)) {
  c <- c + (vet1[i] * vet2[i])
}

cosseno <- c / sqrt(sum(vet1^2)*(sum(vet2^2)))

paste0(round(cosseno * 100, 2),"%")

}
sim_cosseno(text1, text2)
