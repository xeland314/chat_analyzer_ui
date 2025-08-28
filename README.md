# Chat Analyzer UI

A Flutter application to analyze chat logs, providing detailed statistics and visualizations about participants' interactions, sentiments, and communication patterns.

## Features

The application offers a comprehensive analysis of chat files, broken down into several key areas:

### 1. General Statistics (Per Participant)

- **Message Count**: Total number of messages sent by each participant.
- **Multimedia Count**: Total number of multimedia files (images, videos, etc.) shared.
- **Word Frequency**: A list of the most commonly used words, with the ability to ignore default stopwords and add custom words to the ignore list.
- **Emoji Frequency**: A list of the most frequently used emojis.

### 2. Temporal Analysis (Per Participant)

- **Activity Heatmap**: A GitHub-style calendar heatmap that visualizes message frequency throughout the year.
- **Sentiment Heatmap**: A similar calendar heatmap that displays the average sentiment for each day, colored from red (negative) to green (positive).
- **Hourly Activity**: A bar chart showing the most active hours of the day for sending messages.
- **Yearly Filter**: All heatmap analyses can be filtered by year using a simple dropdown menu.

### 3. Interaction Analysis (Global)

This section analyzes the dynamics of the conversation between all participants.

- **Automatic Conversation Threshold**: The app automatically detects the "natural" time gap that separates one conversation from the next (e.g., 45 minutes of inactivity).
- **Interactive Threshold Adjustment**: You can manually adjust this conversation threshold with a slider to see how the analysis changes in real-time.
- **Conversation Starters & Enders**: A grouped bar chart that shows who tends to initiate and who tends to end conversations most often.
- **Average Response Time**: A bar chart comparing how quickly each participant typically replies, measured in minutes.
- **Reply Matrix**: A detailed data table showing who replies to whom and the frequency of those replies.

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Charting**: `fl_chart`
- **Heatmaps**: `flutter_heatmap_calendar`
