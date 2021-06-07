
url <- "https://der.es.gov.br/tabela-referencia-de-precos-e-composicoes-de-custos-unitarios"

# cria_caminho <- function(url) {
#   paste0(url,
caminhos <- url |>
  rvest::read_html() |>
  rvest::html_nodes("a") |>
  rvest::html_attr("href") |>
  stringr::str_subset("\\.+pdf") |>
  stringr::str_subset("Referencial") |>
  stringr::str_subset("om%20desonera") |>
  stringr::str_subset("TRANSPORTE", negate = TRUE) |>
  stringr::str_subset("ranspor", negate = TRUE) |>
  stringr::str_subset("MATERIA", negate = TRUE) |>
  stringr::str_subset("ateria", negate = TRUE) |>
  stringr::str_subset("MAO", negate = TRUE) |>
  stringr::str_subset("Mao", negate = TRUE) |>
  stringr::str_subset("MÃO", negate = TRUE) |>
  stringr::str_subset("Mão", negate = TRUE) |>
  stringr::str_subset("COMPOSI", negate = TRUE) |>
  stringr::str_subset("omposi", negate = TRUE) |>
  stringr::str_subset("EQUIP", negate = TRUE) |>
  stringr::str_subset("quipam", negate = TRUE) |>
  stringr::str_subset("NOTA", negate = TRUE) |>
  stringr::str_subset("Nota", negate = TRUE) |>
  stringr::str_subset("Relat", negate = TRUE) |>
  stringr::str_subset("Resolução%20SETOP%", negate = TRUE)


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
  caminhos |> purrr::map( ~ stringr::str_extract(.x, "([a-z|A-Z]+)(_|%20|-)[0-9]{4}"))

file_names <- as.data.frame(do.call(rbind, file_names))

file_names <- unlist(file_names$V1)

file_names <- stringr::str_replace(file_names, "-", "_")

file_names <- stringr::str_replace(file_names, "%20", "_")

file_names <- stringr::str_to_lower(file_names)

temp <- stringr::str_split(file_names, "_")

temp <- as.data.frame((do.call(rbind, temp)))

# Criando nomes para os Diretórios
dir_names <-
  tidyr::expand_grid(temp$V2, temp$V1) |>
  glue::glue_data("data-raw/DER/{temp$V2}/{temp$V1}/")

file_names <- paste0(dir_names,file_names, ".pdf")

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
# lista_arquivos <-
#   list.files("data-raw/DER",
#              full.names = TRUE,
#              recursive = TRUE)
#
# for (i in 1:length(lista_arquivos)) {
#   z7path = shQuote('C:\\Program Files\\7-Zip\\7z')
#   file = paste0(getwd(), "/", lista_arquivos[i])
#   dest = stringr::str_remove(file, "[0-9]{4}_[0-9]{2}\\.rar")
#   cmd = paste(z7path, ' e ', file, ' -y -o', dest, '/', sep = '')
#   shell(cmd)
#
#   unlink(lista_arquivos[i])
# }
#
# # Apagando diretórios vazios
# lista_diretorios <-
#   list.dirs("data-raw/DER",
#             full.names = TRUE,
#             recursive = TRUE)
#
# for (i in 1:length(lista_diretorios)) {
#   icesTAF::rmdir(list.files(lista_diretorios[i], full.names = T), recursive = TRUE)
# }
