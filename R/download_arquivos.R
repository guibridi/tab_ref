######################

library("glue")
library("tidyverse")
library("downloader")
library("fs")
library(rvest)
library(xml2)

mes <- c("01",
         "02",
         "03",
         "04",
         "05",
         "06",
         "07",
         "08",
         "09",
         "10",
         "11",
         "12")

ano <- c("2016",
         "2017",
         "2018",
         "2019",
         "2020",
         "2021")

# Criando uma string com os endereços das URLs
urls <-
  tidyr::expand_grid(mes, ano) |>
  glue::glue_data(
    "https://tfm.sistemas.cesan.com.br/files/e-doc/{ano}/{mes}/"
  )

cria_caminho <- function(url) {
  paste0(url,
         url |>
           rvest::read_html() |>
           rvest::html_nodes("a") |>
           rvest::html_attr("href") |>
           stringr::str_subset("^[SERV+TAB+].+pdf"))
}

caminhos <- urls |> purrr::map(safely(~cria_caminho(.x), quiet = TRUE))

caminhos <- as.data.frame(do.call(rbind, caminhos))

caminhos[2] <- NULL

caminhos <- unlist(caminhos$result)

# Criando nomes para os arquivos
# file_names <-
#   tidyr::expand_grid(mes, ano) %>%
#   glue_data("data-raw/CESAN/{ano}/{mes}/{mes}{ano}.pdf")

file_names <- caminhos |> purrr::map(~stringr::str_extract(.x, "[0-9]{4}(/)[0-9]{2}"))

file_names <- as.data.frame(do.call(rbind, file_names))

file_names <- unlist(file_names$V1)

file_names <- stringr::str_replace(file_names, "/", "_")

temp <- stringr::str_split(file_names, "_")

temp <- as.data.frame((do.call(rbind, temp)))

# Criando nomes para os Diretórios
dir_names <-
  tidyr::expand_grid(temp$V1, temp$V2) |>
  glue::glue_data("data-raw/CESAN/{temp$V1}/{temp$V2}/")

file_names <- paste0(dir_names,file_names, ".pdf")

# Criando os diretórios
dir_names |> purrr::walk(dir.create, recursive = TRUE)

# Fazendo download dos arquivos
safe_download <-
  purrr::safely( ~ download(.x , .y, mode = "wb"))

purrr::walk2(caminhos, file_names, safe_download)

# Apagando diretórios vazios
lista_diretorios <-
  list.dirs("data-raw/CESAN", full.names = TRUE, recursive = TRUE)

for (i in 1:length(lista_diretorios)) {
  icesTAF::rmdir(list.files(lista_diretorios[i], full.names = T), recursive = TRUE)
}

# Descompactando os arquivos baixados
# lista_arquivos <-
#   list.files("data-raw/CESAN", full.names = TRUE, recursive = TRUE)
#
# for (i in 1:length(lista_arquivos)) {
#   unzip(lista_arquivos[i], exdir = path_dir(lista_arquivos[i]))
#   unlink(lista_arquivos[i])
# }
