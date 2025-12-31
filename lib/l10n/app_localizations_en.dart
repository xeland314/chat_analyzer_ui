// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get name => 'Chat Analyzer';

  @override
  String get home_action_tooltip => 'View Full Chat';

  @override
  String get home_action_display => 'Display Options';

  @override
  String get home_action_reset => 'Reset Analysis';

  @override
  String get home_action_logs => 'View Logs';

  @override
  String get initial_view_message_1 => 'Drag and drop your .txt file here';

  @override
  String get initial_view_message_2 => 'or';

  @override
  String get initial_view_message_3 => 'Load chat file (.txt)';

  @override
  String get initial_view_credits_button => 'Credits';

  @override
  String get cat_phrase_1 => 'Meow!';

  @override
  String get cat_phrase_2 => 'Purr.';

  @override
  String get cat_phrase_3 => 'Nyan!';

  @override
  String get cat_phrase_4 => 'Analyzing chats...';

  @override
  String get cat_phrase_5 => 'I saw something I shouldn\'t have seen...';

  @override
  String get cat_phrase_6 => 'Cat working, don\'t disturb...';

  @override
  String get cat_phrase_7 => 'Reading messages...';

  @override
  String get cat_phrase_8 => 'Counting emojis... 😼';

  @override
  String get cat_phrase_9 => 'I will conquer the world... or just the chat';

  @override
  String get cat_phrase_10 => 'Cleaning paws... almost done.';

  @override
  String get credits_modal_title => 'Credits';

  @override
  String get credits_modal_intro => 'Developed by xeland314.';

  @override
  String get credits_modal_my_name => '(Christopher Villamarin), 2025.';

  @override
  String get credits_modal_github_profile => 'GitHub Profile';

  @override
  String get credits_modal_portfolio => 'Portfolio';

  @override
  String get credits_modal_donations => 'Donations';

  @override
  String get credits_modal_close_button => 'Close';

  @override
  String get credits_modal_buy_me_a_cookie_semantic_label => 'Buy me a cookie at https://www.buymeacoffee.com/xeland314';

  @override
  String get credits_modal_buy_me_a_coffee_semantic_label => 'Buy Me a Coffee at ko-fi.com/C0C41DCI4T';

  @override
  String get disclaimer_modal_text => 'This app only analyzes chats that you manually export from WhatsApp.';

  @override
  String get disclaimer_modal_privacy_notice_title => 'Privacy Notice';

  @override
  String get disclaimer_modal_privacy_notice_content => 'This application only processes chats that you manually export from WhatsApp. It does not access your account or automatically collect information. All data is analyzed locally on your device and sensitive information is anonymized to protect the privacy of third parties.';

  @override
  String get disclaimer_modal_privacy_notice_close_button => 'Close';

  @override
  String get disclaimer_modal_privacy_notice_touch_to_view => 'Tap here to see the full notice';

  @override
  String get display_options_dialog_title => 'Display Options';

  @override
  String get display_options_dialog_number_of_words_to_display => 'Number of words to display';

  @override
  String get display_options_dialog_ignored_words => 'Ignored Words';

  @override
  String get display_options_dialog_add_a_word_to_ignore => 'Add a word to ignore';

  @override
  String get display_options_dialog_cancel_button => 'Cancel';

  @override
  String get display_options_dialog_save_button => 'Save';

  @override
  String get loading_view_pixel_cat_semantic_label => 'Pixelated cat working';

  @override
  String get chat_date_selector_full_chat => 'Full Chat';

  @override
  String get chat_message_list_no_messages => 'No messages on this date.';

  @override
  String activity_heatmap_message_activity(Object year) {
    return 'Message Activity ($year)';
  }

  @override
  String get activity_heatmap_no_message_activity => 'No message activity for this year.';

  @override
  String activity_heatmap_messages_on_date(Object count, Object date) {
    return '$count messages on $date.';
  }

  @override
  String get activity_heatmap_close_button => 'Close';

  @override
  String get advanced_analysis_view_title => 'Hidden Insights';

  @override
  String get advanced_analysis_view_reply_matrix_title => 'Reply Matrix';

  @override
  String get advanced_analysis_view_reply_matrix_info => 'This table shows how many replies each participant received from others.';

  @override
  String get advanced_analysis_view_markov_chain_title => 'Conversation Flow';

  @override
  String get advanced_analysis_view_markov_chain_info => 'How likely it is for one person to reply after another.';

  @override
  String get analysis_result_view_advanced_analysis_title => 'Advanced Analysis';

  @override
  String get analysis_result_view_view_advanced_analysis_button => 'View Advanced Analysis';

  @override
  String get analysis_result_view_chat_analysis_report_filename => 'chat_analysis_report';

  @override
  String get composite_affinity_view_title => 'Strong Connections';

  @override
  String get composite_affinity_view_from_to => 'From \\ To';

  @override
  String get dashboard_view_title => 'Group Summary';

  @override
  String get emitter_similarity_view_title => 'Similar Communication Styles';

  @override
  String get emitter_similarity_view_participant_participant => 'Participant \\ Participant';

  @override
  String get frequency_list_view_no_data => 'No data found.';

  @override
  String get hourly_activity_chart_title => 'Most Active Hours';

  @override
  String hourly_activity_chart_hour(Object hour) {
    return '${hour}h';
  }

  @override
  String hourly_activity_chart_messages_tooltip(Object count) {
    return '$count messages';
  }

  @override
  String get markov_chain_view_matrix_copied_snackbar => 'Matrix copied to clipboard (CSV/TSV format)';

  @override
  String get markov_chain_view_title => 'Markov Chain - Transition Probabilities';

  @override
  String get markov_chain_view_from_to => 'From \\ To';

  @override
  String get markov_chain_view_copy_matrix_button => 'Copy Transition Matrix';

  @override
  String get markov_chain_view_export_matrix_button => 'Export Transition Matrix';

  @override
  String get matrix_squared_view_title => 'Normalized Indirect Influence (M²)';

  @override
  String get matrix_squared_view_from_to => 'From \\ To';

  @override
  String participant_stats_view_subtitle(Object messageCount, Object multimediaCount) {
    return '$messageCount messages, $multimediaCount multimedia files';
  }

  @override
  String get participant_stats_view_most_common_words => 'Most Common Words';

  @override
  String get participant_stats_view_most_common_emojis => 'Most Common Emojis';

  @override
  String get receiver_similarity_view_title => 'Similar Communication Roles';

  @override
  String get receiver_similarity_view_participant_participant => 'Participant \\ Participant';

  @override
  String get reply_matrix_table_copied_snackbar => 'Reply table copied to clipboard (TSV format)';

  @override
  String get reply_matrix_table_replier_to => 'Replier \\ To';

  @override
  String get reply_matrix_table_out_degree => 'Messages sent';

  @override
  String get reply_matrix_table_balance => 'Balance (sent - received)';

  @override
  String get reply_matrix_table_title => 'Who Replies to Whom';

  @override
  String get reply_matrix_table_in_degree => 'Messages received';

  @override
  String get reply_matrix_table_copy_button => 'Copy Reply Table';

  @override
  String get display_options_dialog_language_selector_title => 'Language';

  @override
  String get language_english => 'English';

  @override
  String get language_spanish => 'Spanish';

  @override
  String get response_time_chart_title => 'Average Response Time';

  @override
  String get sentiment_bar_chart_title => 'Sentiment Analysis';

  @override
  String sentiment_bar_chart_positive_tooltip(Object percent) {
    return 'Positive: $percent%';
  }

  @override
  String sentiment_bar_chart_negative_tooltip(Object percent) {
    return 'Negative: $percent%';
  }

  @override
  String sentiment_bar_chart_neutral_tooltip(Object percent) {
    return 'Neutral: $percent%';
  }

  @override
  String sentiment_bar_chart_positive_legend(Object count) {
    return '$count positive';
  }

  @override
  String sentiment_bar_chart_negative_legend(Object count) {
    return '$count negative';
  }

  @override
  String sentiment_bar_chart_neutral_legend(Object count) {
    return '$count neutral';
  }

  @override
  String sentiment_heatmap_title(Object year) {
    return 'Sentiment Trend ($year)';
  }

  @override
  String get sentiment_heatmap_no_data => 'No sentiment data for this year.';

  @override
  String get sentiment_heatmap_positive => 'Positive';

  @override
  String get sentiment_heatmap_negative => 'Negative';

  @override
  String get sentiment_heatmap_neutral => 'Neutral';

  @override
  String sentiment_heatmap_snackbar_content(Object date, Object score, Object sentimentText) {
    return '$sentimentText sentiment ($score) on $date.';
  }

  @override
  String get sentiment_heatmap_close_button => 'Close';

  @override
  String get starters_enders_view_title => 'Conversation Starters & Enders';

  @override
  String get starters_enders_view_starters_title => 'Starters';

  @override
  String get starters_enders_view_enders_title => 'Enders';

  @override
  String get temporal_analysis_view_title => 'Temporal Analysis';

  @override
  String get threshold_slider_title => 'Conversation Threshold';

  @override
  String threshold_slider_description(Object duration) {
    return 'Detected natural threshold: $duration. Use the slider to adjust.';
  }

  @override
  String get equity_gauges_title => 'Participation Equity';

  @override
  String get equity_gauges_speaking_equity => 'Speaking Equity';

  @override
  String get equity_gauges_listening_equity => 'Listening Equity';

  @override
  String get equity_gauges_description => '(0 = perfect equality, 1 = perfect inequality)';

  @override
  String get influence_podium_title => 'Influence Podium';

  @override
  String get interactive_network_graph_title => 'Communication Network';

  @override
  String get network_size_mode_label => 'Avatar Size:';

  @override
  String get network_size_mode_influence => 'By Influence';

  @override
  String get network_size_mode_uniform => 'Uniform (20)';

  @override
  String get key_relationships_title => 'Key Relationships';

  @override
  String get key_relationships_strong_pair => 'Strong Pair';

  @override
  String get key_relationships_monologue => 'Monologue';

  @override
  String key_relationships_reciprocity(Object reciprocity) {
    return 'Reciprocity: $reciprocity';
  }

  @override
  String get markov_simulation_view_button => '🔮 Simulate conversation';

  @override
  String markov_simulation_view_length(Object length) {
    return 'Length: $length messages';
  }

  @override
  String get markov_simulation_view_no_simulation => 'No simulation generated yet';

  @override
  String get top_brokers_cards_title => 'Top Brokers';

  @override
  String get top_brokers_cards_no_brokers_message => 'No significant brokers found in this conversation. This suggests that communication is linear (A -> B -> C) or dispersed, without a single crucial \"bridge\" connecting other pairs of users.';

  @override
  String top_brokers_cards_broker_score(Object score) {
    return 'Broker Score: $score';
  }

  @override
  String get top_brokers_cards_broker_description => 'This user acts as a key bridge between other participants.';

  @override
  String get top_transitions_view_title => 'Who Replies to Whom?';

  @override
  String top_transitions_view_description(Object maxTransitions, Object topCount) {
    return 'Top $topCount of $maxTransitions transitions';
  }

  @override
  String get log_title => 'Log';

  @override
  String get log_empty => '(empty)';

  @override
  String get info_wrapper_info_button => 'What does this mean?';

  @override
  String get export_button_label => 'Export';

  @override
  String get export_csv => 'Export as CSV';

  @override
  String get export_json => 'Export as JSON';

  @override
  String get export_yaml => 'Export as YAML';

  @override
  String get export_toon => 'Export as TOON';

  @override
  String get export_image => 'Export Image';

  @override
  String export_exported_to(Object path) {
    return 'Exported to: $path';
  }

  @override
  String export_saved_image(Object path) {
    return 'Image saved to: $path';
  }

  @override
  String get export_error_no_directory => 'Could not find a suitable directory to save the file.';

  @override
  String export_error_exporting(Object error) {
    return 'Error exporting: $error';
  }

  @override
  String get export_no_data_provided => 'No structured data provided to export.';

  @override
  String get open_folder_action => 'Open Folder';

  @override
  String get share_message_analysis => 'Check out my chat analysis!';

  @override
  String share_exported_text(Object file) {
    return 'Exported $file';
  }
}
