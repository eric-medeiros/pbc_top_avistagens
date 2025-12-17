library(here)
library(xlsx)
library(dplyr)
library(sf)
library(spatstat)
library(terra)

# caminhos
caminho_banco <- here("00_data/03_banco/banco_de_dados_pop_esp_2020-2025.rds")
caminho_area_agua <- here("00_data/02_georefs/amostragem_area.gpkg")
pasta_output <- here("02_outputs")

# função para calcular limiar
calcular_limiar <- function(raster, prob) {
  valores <- terra::values(raster, na.rm = TRUE)
  valores_ordenados <- sort(valores, decreasing = TRUE)
  soma_acumulada <- cumsum(valores_ordenados)
  total <- sum(valores_ordenados)
  indice_limiar <- which.max(soma_acumulada >= (prob * total))
  result <- valores_ordenados[indice_limiar] 
  return(result)
}

# dados
bd <- readRDS(caminho_banco)

# polígono da área (barreira) e 
area_sf <- st_read(caminho_area_agua) %>% 
  st_transform(31983)

# janela para o spatstat
win <- as.owin(area_sf)

# pontos em sf projetados
dados_sf <-
  bd$identificacoes %>%
  filter(!is.na(lng)) %>%
  left_join(bd$avistagens %>% select(saida, grupo, tam_grupo, tam_min, tam_max) %>% unique(),
            by = c("saida", "grupo"),
            relationship = "many-to-many") %>%
  st_as_sf(coords = c("lng","lat"), crs = 4326) %>% 
  st_transform(crs = 31983) %>%
  mutate(tam = case_when(!is.na(as.numeric(tam_grupo)) ~ as.numeric(tam_grupo),
                         !is.na(as.numeric(tam_min)) ~ (as.numeric(tam_min) + as.numeric(tam_max))/2,
                         .default = as.numeric("NA"))) %>%
  filter(!is.na(tam))

ids <- unique(dados_sf$id)

if (!dir.exists(pasta_output)) { dir.create(pasta_output) }

for (i in seq(length(ids))) {
  
  dados_sf_ind <- dados_sf %>% filter(id == ids[i])
  
  # filtro pela area de amostragem e conversão para ppp dentro da janela
  dados_ppp <- 
    dados_sf_ind %>%
    st_intersection(area_sf) %>%
    as.ppp(W = win)

  # rodar o kernel density com pesos
  dens <- density.ppp(dados_ppp, 
                      sigma = 500, # raio do kernel em metros
                      edge = TRUE)
  
  # converte para raster do pacote terra
  dens_raster <- rast(dens)
  crs(dens_raster) <- "EPSG:31983"
  
  # calcular o limiar para 50 e 95
  limiar_50 <- calcular_limiar(dens_raster, 0.50)
  limiar_95 <- calcular_limiar(dens_raster, 0.95)
  
  # criar máscara: mantém apenas valores >= limiar, NA nos demais
  mascara_95 <- dens_raster
  mascara_95[mascara_95 < limiar_95] <- NA
  
  mascara_50 <- dens_raster
  mascara_50[mascara_50 < limiar_50] <- NA
  
  # converter para polígonos para depois
  p95 <-
    as.polygons(mascara_95, dissolve = TRUE) %>%
    st_as_sf()
  p50 <-
    as.polygons(mascara_50, dissolve = TRUE) %>%
    st_as_sf()
  
  caminho_pontos <- here(pasta_output, paste0("pontos_", ids[i],".gpkg"))
  caminho_kernel <- here(pasta_output, paste0("kernel_", ids[i],".tif"))
  caminho_p95 <- here(pasta_output, paste0("p95_", ids[i],".gpkg"))
  caminho_p50 <- here(pasta_output, paste0("p50_", ids[i],".gpkg"))
  
  # salva pontos de dados, raster de kernel e polígonos de p50 e p95 como arquivo georreferenciado
  dados_sf_ind %>% st_write(caminho_pontos, delete_dsn = TRUE)
  dens_raster %>% writeRaster(caminho_kernel, overwrite = TRUE)
  p95 %>% st_write(caminho_p95, delete_dsn = TRUE)
  p50 %>% st_write(caminho_p50, delete_dsn = TRUE)
}
