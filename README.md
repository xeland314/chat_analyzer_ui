# Chat Analyzer UI

A Flutter application to analyze chat logs, providing detailed statistics and visualizations about participants' interactions, sentiments, and communication patterns.

## Features

The application offers a comprehensive analysis of chat files, broken down into several key areas:

- **Android Intent Handling**: Seamlessly open and analyze chat files directly from other applications on Android.
- **Log Viewer Copy Button**: Easily copy application logs to the clipboard for debugging or sharing.
- **Image Export with Watermark**: Export analysis results as shareable images with a custom watermark. On Linux, images are saved locally.

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
  - **In-degree and Out-degree**: Identify who talks more (out-degree) and who is replied to more (in-degree).
  - **Balance**: The difference between out-degree and in-degree, indicating if a participant talks more than they receive replies.
- **Reciprocity Index**: A global metric (0-1) indicating the symmetry of communication within the chat.
- **Reciprocity Heatmap**: A visual representation of the reciprocity between each pair of participants.
- **PageRank**: A ranking of participants based on their communication influence within the chat network.
- **Matrix Exponentiation (M²)**: A normalized matrix showing indirect influence, revealing how participants influence others through intermediaries.
- **Composite Affinity**: A metric combining direct and indirect influence to identify strong communication ties.
- **Broker Detection**: Identifies participants who act as communication bridges between others.
- **Markov Chain View**: Displays the transition probabilities between participants, showing the likelihood of one participant replying to another.
- **Emitter Similarity**: Identifies participants with similar outgoing communication patterns.
- **Receiver Similarity**: Identifies participants with similar incoming communication patterns.
- **Participation Equity (Gini Coefficient)**: Measures the equality of speaking and listening participation among chat members.

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Charting**: `fl_chart`
- **Heatmaps**: `flutter_heatmap_calendar`
