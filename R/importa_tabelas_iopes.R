arquivos <-
  list.files(
    "data-raw/IOPES",
    full.names = TRUE,
    include.dirs = TRUE,
    recursive = TRUE,
    pattern = "xlsx"
  )

arquivos <- arquivos |>
  stringr::str_subset("servicos")

for (arquivo in arquivos) {
  nome <- stringr::str_extract(arquivo, "[0-9]{4}\\/[0-9]{2}")
  nome <- stringr::str_replace(nome, "/", "_")
  tabela <- as.name(nome)
  tabela <- readxl::read_excel(arquivo,
                               col_names = FALSE,
                               skip = 12)
  names(tabela) <-
    c(
      "codigo",
      "fonte",
      "descricao",
      "unidade",
      "quantidade",
      "preco_unitario",
      "preco_total"
    )

  tabela <- tabela[complete.cases(tabela), ]

  tabela$codigo <- stringr::str_replace(tabela$codigo, "'", "")


  dir_extr <-
    stringr::str_remove(arquivo, "(?<=[0-9]{4}\\/[0-9]{2}\\/)(.+\\.xlsx)")
  readr::write_rds(tabela, file = eval(paste0(dir_extr, "/", nome, ".rds")), compress = "gz")

}
