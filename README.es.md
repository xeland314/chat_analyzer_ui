# Analizador de Chats (UI)

Una aplicación de Flutter para analizar historiales de chat, proveyendo estadísticas detalladas y visualizaciones sobre las interacciones, sentimientos y patrones de comunicación de los participantes.

## Funcionalidades

La aplicación ofrece un análisis completo de los archivos de chat, desglosado en varias áreas clave:

### 1. Estadísticas Generales (Por Participante)

- **Conteo de Mensajes**: Número total de mensajes enviados por cada participante.
- **Conteo de Multimedia**: Número total de archivos multimedia (imágenes, videos, etc.) compartidos.
- **Frecuencia de Palabras**: Una lista de las palabras más usadas, con la habilidad de ignorar "stopwords" (palabras comunes) y añadir palabras personalizadas a la lista de ignorados.
- **Frecuencia de Emojis**: Una lista de los emojis más utilizados.

### 2. Análisis Temporal (Por Participante)

- **Mapa de Calor de Actividad**: Un mapa de calor estilo calendario de GitHub que visualiza la frecuencia de mensajes a lo largo del año.
- **Mapa de Calor de Sentimiento**: Un mapa de calor similar que muestra el sentimiento promedio de cada día, coloreado desde el rojo (negativo) al verde (positivo).
- **Actividad por Hora**: Un gráfico de barras que muestra las horas del día más activas para el envío de mensajes.
- **Filtro Anual**: Todos los análisis de mapas de calor pueden ser filtrados por año usando un simple menú desplegable.

### 3. Análisis de Interacción (Global)

Esta sección analiza la dinámica de la conversación entre todos los participantes.

- **Umbral de Conversación Automático**: La aplicación detecta automáticamente el lapso de tiempo "natural" que separa una conversación de la siguiente (ej: 45 minutos de inactividad).
- **Ajuste de Umbral Interactivo**: Puedes ajustar manualmente este umbral de conversación con un slider para ver cómo cambia el análisis en tiempo real.
- **Iniciadores y Finalizadores de Conversaciones**: Un gráfico de barras agrupado que muestra quién tiende a iniciar y quién tiende a terminar las conversaciones más a menudo.
- **Tiempo de Respuesta Promedio**: Un gráfico de barras que compara cuán rápido responde típicamente cada participante, medido en minutos.
- **Matriz de Respuestas**: Una tabla de datos detallada que muestra quién responde a quién y la frecuencia de dichas respuestas.

## Stack Tecnológico

- **Framework**: Flutter
- **Lenguaje**: Dart
- **Gráficos**: `fl_chart`
- **Mapas de Calor**: `flutter_heatmap_calendar`
