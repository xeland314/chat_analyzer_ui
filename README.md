# Chat Analyzer UI

A cross-platform Flutter application to import, parse, and analyze chat logs (like those from WhatsApp), providing detailed statistics and visualizations about participants' interactions, sentiments, and communication patterns.

## Key Features

### 1. Data Input & Compatibility

- **Cross-Platform:** Fully functional on Android, iOS, Linux, Windows, macOS, and Web.
- **Flexible Import:** Load chat history `.txt` files using:
    - **File Picker:** Select the file from your device's storage.
    - **Drag-and-Drop:** Drag the file directly onto the app window (on desktop platforms).
    - **Share Intent:** Open chat files directly from other apps (e.g., WhatsApp) on mobile.
- **Advanced Parsing:** The app intelligently parses the chat file to identify:
    - Messages, authors, dates, and times.
    - Emojis and links.
    - System messages (e.g., "User joined the group").

### 2. Core Analysis Metrics

- **General Statistics (per user):**
    - **Message & Word Count:** Total messages and words sent.
    - **Emoji & Link Count:** Total emojis and links shared.
    - **Word Cloud:** A visual representation of the most frequently used words, with advanced filtering of common "stopwords" in both English and Spanish.
    - **Emoji Frequency:** A list of the most used emojis.
- **Temporal Analysis:**
    - **Activity Heatmap:** A GitHub-style calendar heatmap visualizing message frequency throughout the year.
    - **Hourly Activity:** A bar chart showing the most active hours of the day for sending messages.
- **Sentiment Analysis:**
    - **Message-level Sentiment:** Each message is analyzed for positive, negative, or neutral sentiment.
    - **Sentiment Heatmap:** A calendar view showing the average sentiment for each day, colored from red (negative) to green (positive).

### 3. Interaction & Social Network Analysis

This section analyzes the dynamics of the conversation as a social network.

- **Conversation Detection:**
    - **Automatic Threshold:** The app automatically detects the natural time gap that separates one conversation from the next.
    - **Interactive Adjustment:** Manually adjust the conversation threshold with a slider to see how the analysis changes in real-time.
- **Interaction Metrics:**
    - **Conversation Starters & Enders:** See who tends to initiate and conclude conversations.
    - **Average Response Time:** Compare how quickly each participant typically replies.
- **Graph-Based Network Analysis:**
    - **Reply Matrix:** A detailed table showing who replies to whom and with what frequency.
    - **PageRank:** Identifies the most "influential" participants in the conversation based on who gets replied to by other influential members.
    - **Betweenness Centrality:** Measures how often a participant acts as a "bridge" or "broker" in the communication flow between other members. This helps identify key connectors in the group.

### 4. Visualizations & Export

- **Interactive Charts:** Most metrics are presented using clear, interactive charts and graphs from the `fl_chart` library.
- **Graph Visualizer:** A visual representation of the interaction network using the `flutter_force_directed_graph` library.
- **Image Export:** Share or save the analysis results as a convenient image.

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Dependencies**:
    - **UI & Charting**: `fl_chart`, `flutter_heatmap_calendar`
    - **File Handling**: `file_picker`, `desktop_drop`, `receive_sharing_intent`
    - **Analysis**: `dart_sentiment`, `flutter_force_directed_graph`
