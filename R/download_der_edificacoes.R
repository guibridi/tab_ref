
url <- "https://der.es.gov.br/referencial-de-precos"

# cria_caminho <- function(url) {
#   paste0(url,
caminhos <- url |>
  rvest::read_html() |>
  rvest::html_nodes("a") |>
  rvest::html_attr("href") |>
  stringr::str_subset("\\.+rar") |>
  stringr::str_subset("Edifica") |>
  stringr::str_subset("SERIEHISTORICA", negate = TRUE)

prefix <- "https://der.es.gov.br"

caminhos <- caminhos |> purrr::map(~ paste0(prefix, .x))

#          )
# }
#
# caminhos <- urls |> purrr::map(safely(~cria_caminho(.x), quiet = TRUE))
#
caminhos <- as.data.frame(do.call(rbind, caminhos))
#
# caminhos[2] <- NULL
#
caminhos <- unlist(caminhos$V1)

caminhos <- unique(caminhos)

# Criando nomes para os arquivos
# file_names <-
#   tidyr::expand_grid(mes, ano) %>%
#   glue_data("data-raw/CESAN/{ano}/{mes}/{mes}{ano}.pdf")

file_names <-
  caminhos |> purrr::map( ~ stringr::str_extract(.x, "[0-9]{4}(-)[0-9]{2}"))

file_names <- as.data.frame(do.call(rbind, file_names))

file_names <- unlist(file_names$V1)

file_names <- stringr::str_replace(file_names, "-", "_")

temp <- stringr::str_split(file_names, "_")

temp <- as.data.frame((do.call(rbind, temp)))

# Criando nomes para os Diretórios
dir_names <-
  tidyr::expand_grid(temp$V1, temp$V2) |>
  glue::glue_data("data-raw/IOPES/{temp$V1}/{temp$V2}/")

file_names <- paste0(dir_names,file_names, ".rar")

# Criando os diretórios
dir_names |> purrr::walk(dir.create, recursive = TRUE)

# Fazendo download dos arquivos
safe_download <-
  purrr::safely(~ utils::download.file(
    url = .x ,
    destfile =  .y,
    mode = "wb",
    method = "curl"
  ))

purrr::walk2(.x = caminhos, .y = file_names, .f = safe_download)

# Descompactando os arquivos baixados
lista_arquivos <-
  list.files("data-raw/IOPES",
             full.names = TRUE,
             recursive = TRUE)

for (i in 1:length(lista_arquivos)) {
  z7path = shQuote('C:\\Program Files\\7-Zip\\7z')
  file = paste0(getwd(), "/", lista_arquivos[i])
  dest = stringr::str_remove(file, "[0-9]{4}_[0-9]{2}\\.rar")
  cmd = paste(z7path, ' e ', file, ' -y -o', dest, '/', sep = '')
  shell(cmd)

  unlink(lista_arquivos[i])
}

# Apagando diretórios vazios
lista_diretorios <-
  list.dirs("data-raw/IOPES",
            full.names = TRUE,
            recursive = TRUE)

for (i in 1:length(lista_diretorios)) {
  icesTAF::rmdir(list.files(lista_diretorios[i], full.names = T), recursive = TRUE)
}
