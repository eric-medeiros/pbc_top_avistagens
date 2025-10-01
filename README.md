# 📊 PBC - Top Avistagens

Dashboard interativo para análise espacial de padrões de uso de território por indivíduos monitorados.

## 🎯 Objetivo

Este projeto realiza análises de kernel density para mapear e visualizar os padrões de uso de espaço de diferentes indivíduos, gerando mapas interativos com múltiplas camadas de informação.

## 📁 Estrutura do Projeto

```
pbc_top_avistagens/
├── 00_data/
│   ├── 00_dados_brutos/
│   │   └── Tabela_filtrada_Wesley.xlsx
│   ├── 01_tratados_excel/
│   │   └── Dados_Top_Avistagens.xlsx
│   └── 02_georefs/
│       └── amostragem_area.gpkg
├── 01_scripts/
│   └── top_avistagens.R
├── 02_outputs/
│   └── CN001/
│   │   ├── pontos.gpkg
│   │   ├── kernel.tif
│   │   ├── p50.gpkg
│   │   ├── p95.gpkg
│   └── CN002/
│   └── ... (demais indivíduos)
├── 03_mrkdwn/
│   └── leaflet_top_avis.Rmd
└── README.md
```

## 🗂️ Dados

### Fontes
- **Dados_Top_Avistagens.xlsx**: Planilha com registros de avistagens
- **amostragem_area.gpkg**: Polígono da área de estudo

### Saídas Geradas
Para cada indivíduo são gerados 4 arquivos:
- `pontos.gpkg`: Pontos de avistagem
- `kernel.tif`: Raster de densidade kernel
- `p50.gpkg`: Polígono do percentil 50 (área central)
- `p95.gpkg`: Polígono do percentil 95 (área total de uso)

## 🔧 Processamento

### Pré-requisitos
```r
library(here)
library(xlsx)
library(dplyr)
library(sf)
library(spatstat)
library(terra)
```

### Parâmetros da Análise
- **Sistema de coordenadas**: EPSG:31983 (SIRGAS 2000 / UTM zone 23S)
- **Suavização kernel**: Gaussian, sigma = 500m
- **Percentis calculados**: 50% e 95%
- **Saída final**: WGS84 (EPSG:4326) para compatibilidade web

## 📊 Dashboard

### Funcionalidades
- ✅ Mapa interativo com Leaflet
- ✅ 26 indivíduos com cores distintas
- ✅ 4 camadas por indivíduo (Pontos, Kernel, P50, P95)
- ✅ Controle individual de visibilidade
- ✅ Popups informativos com dados das avistagens
- ✅ Múltiplos mapas base (Satélite, Light)

### Como Usar
1. **Abrir** o arquivo `dashboard_top_avistagens.Rmd`
2. **Executar** o código para gerar o HTML
3. **Navegar** pelo mapa interativo
4. **Usar o controle ☰** para gerenciar camadas

## 🎨 Visualização

### Legenda de Cores
- **🟡 Pontos**: Locais de avistagem específicos
- **🔴 Kernel**: Intensidade de uso do território  
- **🔵 P50**: Área central (50% do uso)
- **🟢 P95**: Área total (95% do uso)

### Cores dos Indivíduos
Cada indivíduo recebe uma cor única para fácil identificação no mapa.

## 🚀 Execução

### Processar Dados
```r
source("01_scripts/top_avistagens.R")
```

### Gerar Dashboard
```r
rmarkdown::render("leaflet_top_avis.Rmd")
```

## 📈 Resultados Esperados

- Análise espacial quantitativa do uso do território
- Identificação de áreas centrais vs. áreas de uso extensivo
- Comparação entre padrões de diferentes indivíduos
- Visualização interativa para tomada de decisão

## 👥 Responsáveis

**Eric Medeiros**  
*Análise de Dados Espaciais*

---

*Projeto desenvolvido para o Programa de Monitoramento de Biodiversidade Costeira*
