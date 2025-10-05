# Chat Analyzer UI (Analizador de Chats)

Una aplicación multiplataforma desarrollada con Flutter para importar, procesar y analizar historiales de chat (como los de WhatsApp), proveyendo estadísticas detalladas y visualizaciones sobre las interacciones, sentimientos y patrones de comunicación de los participantes.

## Funcionalidades Clave

### 1. Entrada de Datos y Compatibilidad

- **Multiplataforma:** Totalmente funcional en Android, iOS, Linux, Windows, macOS y Web.
- **Importación Flexible:** Carga archivos de historial de chat en formato `.txt` usando:
    - **Selector de Archivos:** Selecciona el archivo desde el almacenamiento de tu dispositivo.
    - **Arrastrar y Soltar (Drag-and-Drop):** Arrastra el archivo directamente a la ventana de la aplicación (en plataformas de escritorio).
    - **Compartir desde otra App (Share Intent):** Abre archivos de chat directamente desde otras aplicaciones (ej. WhatsApp) en dispositivos móviles.
- **Análisis Inteligente (Parsing):** La aplicación procesa el archivo de chat para identificar:
    - Mensajes, autores, fechas y horas.
    - Emojis y enlaces.
    - Mensajes de sistema (ej. "Usuario se unió al grupo").

### 2. Métricas de Análisis Principales

- **Estadísticas Generales (por usuario):**
    - **Conteo de Mensajes y Palabras:** Total de mensajes y palabras enviadas.
    - **Conteo de Emojis y Enlaces:** Total de emojis y enlaces compartidos.
    - **Nube de Palabras:** Una representación visual de las palabras más frecuentes, con filtrado avanzado de "stopwords" (palabras comunes) en inglés y español.
    - **Frecuencia de Emojis:** Una lista de los emojis más utilizados.
- **Análisis Temporal:**
    - **Mapa de Calor de Actividad:** Un mapa de calor estilo calendario de GitHub que visualiza la frecuencia de mensajes a lo largo del año.
    - **Actividad por Hora:** Un gráfico de barras que muestra las horas del día más activas para el envío de mensajes.
- **Análisis de Sentimiento:**
    - **Sentimiento por Mensaje:** Cada mensaje es analizado para determinar si su sentimiento es positivo, negativo o neutral.
    - **Mapa de Calor de Sentimiento:** Una vista de calendario que muestra el sentimiento promedio de cada día, coloreado desde el rojo (negativo) al verde (positivo).

### 3. Análisis de Interacción y Redes Sociales

Esta sección analiza la dinámica de la conversación como si fuera una red social.

- **Detección de Conversaciones:**
    - **Umbral Automático:** La aplicación detecta automáticamente el lapso de tiempo natural que separa una conversación de la siguiente.
    - **Ajuste Interactivo:** Ajusta manualmente el umbral de conversación con un deslizador para ver cómo cambia el análisis en tiempo real.
- **Métricas de Interacción:**
    - **Iniciadores y Finalizadores de Conversación:** Muestra quién tiende a iniciar y a concluir las conversaciones.
    - **Tiempo de Respuesta Promedio:** Compara cuán rápido responde típicamente cada participante.
- **Análisis de Red Basado en Grafos:**
    - **Matriz de Respuestas:** Una tabla detallada que muestra quién responde a quién y con qué frecuencia.
    - **PageRank:** Identifica a los participantes más "influyentes" en la conversación, basándose en quién recibe respuestas de otros miembros influyentes.
    - **Centralidad de Intermediación (Betweenness Centrality):** Mide la frecuencia con la que un participante actúa como un "puente" o "conector" en el flujo de comunicación entre otros miembros. Esto ayuda a identificar a los conectores clave en el grupo.

### 4. Visualizaciones y Exportación

- **Gráficos Interactivos:** La mayoría de las métricas se presentan usando gráficos claros e interactivos de la librería `fl_chart`.
- **Visualizador de Grafos:** Una representación visual de la red de interacción usando la librería `graphview`.
- **Exportación como Imagen:** Comparte o guarda los resultados del análisis como una imagen.

## Stack Tecnológico

- **Framework**: Flutter
- **Lenguaje**: Dart
- **Dependencias**:
    - **UI y Gráficos**: `fl_chart`, `flutter_heatmap_calendar`
    - **Manejo de Archivos**: `file_picker`, `desktop_drop`, `receive_sharing_intent`
    - **Análisis**: `dart_sentiment`, `graphview`