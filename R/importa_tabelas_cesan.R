arquivos <-
  list.files(
    "data-raw/CESAN",
    full.names = TRUE,
    include.dirs = TRUE,
    recursive = TRUE,
    pattern = "pdf"
  )

for (arquivo in arquivos) {
  tabela_cesan <- data.frame()

  tabela <- data.frame()

  dir_extr <- stringr::str_remove(arquivo, ".pdf")

  dir.create(dir_extr)

  purrr::safely(
    tabulizer::extract_tables(
      arquivo,
      output = "tsv",
      outdir = dir_extr,
      encoding = "UTF-8"
    ),
    quiet = TRUE
  )

  arquivos_tsv <- list.files(dir_extr, full.names = TRUE)

  for (arquivo_tsv in arquivos_tsv) {
    ler_tabela <- purrr::safely(function(arquivo_tsv) {
      readr::read_delim(
        arquivo_tsv,
        "\t",
        escape_double = FALSE,
        locale = readr::locale(
          decimal_mark = ",",
          grouping_mark = ".",
          encoding = "WINDOWS-1252"
        ),
        col_names = FALSE,
        trim_ws = TRUE,
        skip = 1
      )
    }, quiet = TRUE)

    tabela <- ler_tabela(arquivo_tsv)[["result"]]

    tabela <- tabela[complete.cases(tabela),]

    tabela$X1 <-
      stringr::str_split(string = tabela$X1, pattern = "(?<=[0-9]{10})[:space:]",)

    tabela <- tabela |> tidyr::unnest_wider(X1)

    if (ncol(tabela) != 4) {
      next
    }
    else {
      tabela <- tabela
    }


    names(tabela) <-
      c("codigo", "descricao", "unidade", "preco_unitario")

    tabela$codigo <-
      gsub(x = tabela$codigo,
           pattern = "\"",
           replacement = "")

    tabela$descricao <-
      gsub(x = tabela$descricao,
           pattern = "\"",
           replacement = "")

    tabela <- tabela[complete.cases(tabela), ]

    juntar <- purrr::safely(function(t1, t2) {
      rbind(t1, t2)
    }, quiet = TRUE)
    tabela_cesan <- juntar(tabela_cesan, tabela)[["result"]]
    tabela_cesan <- tabela_cesan[complete.cases(tabela_cesan), ]
    tabela_cesan <-
      dplyr::filter(
        tibble::as_tibble(tabela_cesan),
        stringr::str_detect(tabela_cesan$codigo, "[0-9]{10}")
      )

  }

  arquivos_tsv |> unlink(recursive = TRUE,
                         force = TRUE,
                         expand = TRUE)

  tabela_cesan |> readr::write_rds(paste0(dir_extr, ".rds"), compress = "gz")

}
