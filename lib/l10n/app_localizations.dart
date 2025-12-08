import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Chat Analyzer'**
  String get name;

  /// No description provided for @home_action_tooltip.
  ///
  /// In en, this message translates to:
  /// **'View Full Chat'**
  String get home_action_tooltip;

  /// No description provided for @home_action_display.
  ///
  /// In en, this message translates to:
  /// **'Display Options'**
  String get home_action_display;

  /// No description provided for @home_action_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset Analysis'**
  String get home_action_reset;

  /// No description provided for @home_action_logs.
  ///
  /// In en, this message translates to:
  /// **'View Logs'**
  String get home_action_logs;

  /// No description provided for @initial_view_message_1.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop your .txt file here'**
  String get initial_view_message_1;

  /// No description provided for @initial_view_message_2.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get initial_view_message_2;

  /// No description provided for @initial_view_message_3.
  ///
  /// In en, this message translates to:
  /// **'Load chat file (.txt)'**
  String get initial_view_message_3;

  /// No description provided for @initial_view_credits_button.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get initial_view_credits_button;

  /// No description provided for @cat_phrase_1.
  ///
  /// In en, this message translates to:
  /// **'Meow!'**
  String get cat_phrase_1;

  /// No description provided for @cat_phrase_2.
  ///
  /// In en, this message translates to:
  /// **'Purr.'**
  String get cat_phrase_2;

  /// No description provided for @cat_phrase_3.
  ///
  /// In en, this message translates to:
  /// **'Nyan!'**
  String get cat_phrase_3;

  /// No description provided for @cat_phrase_4.
  ///
  /// In en, this message translates to:
  /// **'Analyzing chats...'**
  String get cat_phrase_4;

  /// No description provided for @cat_phrase_5.
  ///
  /// In en, this message translates to:
  /// **'I saw something I shouldn\'t have seen...'**
  String get cat_phrase_5;

  /// No description provided for @cat_phrase_6.
  ///
  /// In en, this message translates to:
  /// **'Cat working, don\'t disturb...'**
  String get cat_phrase_6;

  /// No description provided for @cat_phrase_7.
  ///
  /// In en, this message translates to:
  /// **'Reading messages...'**
  String get cat_phrase_7;

  /// No description provided for @cat_phrase_8.
  ///
  /// In en, this message translates to:
  /// **'Counting emojis... 😼'**
  String get cat_phrase_8;

  /// No description provided for @cat_phrase_9.
  ///
  /// In en, this message translates to:
  /// **'I will conquer the world... or just the chat'**
  String get cat_phrase_9;

  /// No description provided for @cat_phrase_10.
  ///
  /// In en, this message translates to:
  /// **'Cleaning paws... almost done.'**
  String get cat_phrase_10;

  /// No description provided for @credits_modal_title.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits_modal_title;

  /// No description provided for @credits_modal_intro.
  ///
  /// In en, this message translates to:
  /// **'Developed by xeland314.'**
  String get credits_modal_intro;

  /// No description provided for @credits_modal_my_name.
  ///
  /// In en, this message translates to:
  /// **'(Christopher Villamarin), 2025.'**
  String get credits_modal_my_name;

  /// No description provided for @credits_modal_github_profile.
  ///
  /// In en, this message translates to:
  /// **'GitHub Profile'**
  String get credits_modal_github_profile;

  /// No description provided for @credits_modal_portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get credits_modal_portfolio;

  /// No description provided for @credits_modal_donations.
  ///
  /// In en, this message translates to:
  /// **'Donations'**
  String get credits_modal_donations;

  /// No description provided for @credits_modal_close_button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get credits_modal_close_button;

  /// No description provided for @credits_modal_buy_me_a_cookie_semantic_label.
  ///
  /// In en, this message translates to:
  /// **'Buy me a cookie at https://www.buymeacoffee.com/xeland314'**
  String get credits_modal_buy_me_a_cookie_semantic_label;

  /// No description provided for @credits_modal_buy_me_a_coffee_semantic_label.
  ///
  /// In en, this message translates to:
  /// **'Buy Me a Coffee at ko-fi.com/C0C41DCI4T'**
  String get credits_modal_buy_me_a_coffee_semantic_label;

  /// No description provided for @disclaimer_modal_text.
  ///
  /// In en, this message translates to:
  /// **'This app only analyzes chats that you manually export from WhatsApp.'**
  String get disclaimer_modal_text;

  /// No description provided for @disclaimer_modal_privacy_notice_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy Notice'**
  String get disclaimer_modal_privacy_notice_title;

  /// No description provided for @disclaimer_modal_privacy_notice_content.
  ///
  /// In en, this message translates to:
  /// **'This application only processes chats that you manually export from WhatsApp. It does not access your account or automatically collect information. All data is analyzed locally on your device and sensitive information is anonymized to protect the privacy of third parties.'**
  String get disclaimer_modal_privacy_notice_content;

  /// No description provided for @disclaimer_modal_privacy_notice_close_button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get disclaimer_modal_privacy_notice_close_button;

  /// No description provided for @disclaimer_modal_privacy_notice_touch_to_view.
  ///
  /// In en, this message translates to:
  /// **'Tap here to see the full notice'**
  String get disclaimer_modal_privacy_notice_touch_to_view;

  /// No description provided for @display_options_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Display Options'**
  String get display_options_dialog_title;

  /// No description provided for @display_options_dialog_number_of_words_to_display.
  ///
  /// In en, this message translates to:
  /// **'Number of words to display'**
  String get display_options_dialog_number_of_words_to_display;

  /// No description provided for @display_options_dialog_ignored_words.
  ///
  /// In en, this message translates to:
  /// **'Ignored Words'**
  String get display_options_dialog_ignored_words;

  /// No description provided for @display_options_dialog_add_a_word_to_ignore.
  ///
  /// In en, this message translates to:
  /// **'Add a word to ignore'**
  String get display_options_dialog_add_a_word_to_ignore;

  /// No description provided for @display_options_dialog_cancel_button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get display_options_dialog_cancel_button;

  /// No description provided for @display_options_dialog_save_button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get display_options_dialog_save_button;

  /// No description provided for @loading_view_pixel_cat_semantic_label.
  ///
  /// In en, this message translates to:
  /// **'Pixelated cat working'**
  String get loading_view_pixel_cat_semantic_label;

  /// No description provided for @chat_date_selector_full_chat.
  ///
  /// In en, this message translates to:
  /// **'Full Chat'**
  String get chat_date_selector_full_chat;

  /// No description provided for @chat_message_list_no_messages.
  ///
  /// In en, this message translates to:
  /// **'No messages on this date.'**
  String get chat_message_list_no_messages;

  /// No description provided for @activity_heatmap_message_activity.
  ///
  /// In en, this message translates to:
  /// **'Message Activity ({year})'**
  String activity_heatmap_message_activity(Object year);

  /// No description provided for @activity_heatmap_no_message_activity.
  ///
  /// In en, this message translates to:
  /// **'No message activity for this year.'**
  String get activity_heatmap_no_message_activity;

  /// No description provided for @activity_heatmap_messages_on_date.
  ///
  /// In en, this message translates to:
  /// **'{count} messages on {date}.'**
  String activity_heatmap_messages_on_date(Object count, Object date);

  /// No description provided for @activity_heatmap_close_button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get activity_heatmap_close_button;

  /// No description provided for @advanced_analysis_view_title.
  ///
  /// In en, this message translates to:
  /// **'Advanced Interaction Analysis'**
  String get advanced_analysis_view_title;

  /// No description provided for @advanced_analysis_view_reply_matrix_title.
  ///
  /// In en, this message translates to:
  /// **'Reply Matrix'**
  String get advanced_analysis_view_reply_matrix_title;

  /// No description provided for @advanced_analysis_view_reply_matrix_info.
  ///
  /// In en, this message translates to:
  /// **'This table shows the number of replies each participant received from others.'**
  String get advanced_analysis_view_reply_matrix_info;

  /// No description provided for @advanced_analysis_view_markov_chain_title.
  ///
  /// In en, this message translates to:
  /// **'Markov Chain'**
  String get advanced_analysis_view_markov_chain_title;

  /// No description provided for @advanced_analysis_view_markov_chain_info.
  ///
  /// In en, this message translates to:
  /// **'This table shows the probability of a participant replying to another participant.'**
  String get advanced_analysis_view_markov_chain_info;

  /// No description provided for @analysis_result_view_advanced_analysis_title.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analysis'**
  String get analysis_result_view_advanced_analysis_title;

  /// No description provided for @analysis_result_view_view_advanced_analysis_button.
  ///
  /// In en, this message translates to:
  /// **'View Advanced Analysis'**
  String get analysis_result_view_view_advanced_analysis_button;

  /// No description provided for @analysis_result_view_chat_analysis_report_filename.
  ///
  /// In en, this message translates to:
  /// **'chat_analysis_report'**
  String get analysis_result_view_chat_analysis_report_filename;

  /// No description provided for @composite_affinity_view_title.
  ///
  /// In en, this message translates to:
  /// **'Composite Affinity (Direct + Indirect)'**
  String get composite_affinity_view_title;

  /// No description provided for @composite_affinity_view_from_to.
  ///
  /// In en, this message translates to:
  /// **'From \\ To'**
  String get composite_affinity_view_from_to;

  /// No description provided for @dashboard_view_title.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard_view_title;

  /// No description provided for @emitter_similarity_view_title.
  ///
  /// In en, this message translates to:
  /// **'Emitter Similarity (Similar Communication Profiles)'**
  String get emitter_similarity_view_title;

  /// No description provided for @emitter_similarity_view_participant_participant.
  ///
  /// In en, this message translates to:
  /// **'Participant \\ Participant'**
  String get emitter_similarity_view_participant_participant;

  /// No description provided for @frequency_list_view_no_data.
  ///
  /// In en, this message translates to:
  /// **'No data found.'**
  String get frequency_list_view_no_data;

  /// No description provided for @hourly_activity_chart_title.
  ///
  /// In en, this message translates to:
  /// **'Most Active Hours'**
  String get hourly_activity_chart_title;

  /// No description provided for @hourly_activity_chart_hour.
  ///
  /// In en, this message translates to:
  /// **'{hour}h'**
  String hourly_activity_chart_hour(Object hour);

  /// No description provided for @hourly_activity_chart_messages_tooltip.
  ///
  /// In en, this message translates to:
  /// **'{count} messages'**
  String hourly_activity_chart_messages_tooltip(Object count);

  /// No description provided for @markov_chain_view_matrix_copied_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Matrix copied to clipboard (CSV/TSV format)'**
  String get markov_chain_view_matrix_copied_snackbar;

  /// No description provided for @markov_chain_view_title.
  ///
  /// In en, this message translates to:
  /// **'Markov Chain - Transition Probabilities'**
  String get markov_chain_view_title;

  /// No description provided for @markov_chain_view_from_to.
  ///
  /// In en, this message translates to:
  /// **'From \\ To'**
  String get markov_chain_view_from_to;

  /// No description provided for @markov_chain_view_copy_matrix_button.
  ///
  /// In en, this message translates to:
  /// **'Copy Transition Matrix'**
  String get markov_chain_view_copy_matrix_button;

  /// Label for exporting the transition matrix to a file
  ///
  /// In en, this message translates to:
  /// **'Export Transition Matrix'**
  String get markov_chain_view_export_matrix_button;

  /// No description provided for @matrix_squared_view_title.
  ///
  /// In en, this message translates to:
  /// **'Normalized Indirect Influence (M²)'**
  String get matrix_squared_view_title;

  /// No description provided for @matrix_squared_view_from_to.
  ///
  /// In en, this message translates to:
  /// **'From \\ To'**
  String get matrix_squared_view_from_to;

  /// No description provided for @participant_stats_view_subtitle.
  ///
  /// In en, this message translates to:
  /// **'{messageCount} messages, {multimediaCount} multimedia files'**
  String participant_stats_view_subtitle(Object messageCount, Object multimediaCount);

  /// No description provided for @participant_stats_view_most_common_words.
  ///
  /// In en, this message translates to:
  /// **'Most Common Words'**
  String get participant_stats_view_most_common_words;

  /// No description provided for @participant_stats_view_most_common_emojis.
  ///
  /// In en, this message translates to:
  /// **'Most Common Emojis'**
  String get participant_stats_view_most_common_emojis;

  /// No description provided for @receiver_similarity_view_title.
  ///
  /// In en, this message translates to:
  /// **'Receiver Similarity (Similar Roles)'**
  String get receiver_similarity_view_title;

  /// No description provided for @receiver_similarity_view_participant_participant.
  ///
  /// In en, this message translates to:
  /// **'Participant \\ Participant'**
  String get receiver_similarity_view_participant_participant;

  /// No description provided for @reply_matrix_table_copied_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Reply table copied to clipboard (TSV format)'**
  String get reply_matrix_table_copied_snackbar;

  /// No description provided for @reply_matrix_table_replier_to.
  ///
  /// In en, this message translates to:
  /// **'Replier \\ To'**
  String get reply_matrix_table_replier_to;

  /// No description provided for @reply_matrix_table_out_degree.
  ///
  /// In en, this message translates to:
  /// **'Out-degree (Replies Sent)'**
  String get reply_matrix_table_out_degree;

  /// No description provided for @reply_matrix_table_balance.
  ///
  /// In en, this message translates to:
  /// **'Balance (Out - In)'**
  String get reply_matrix_table_balance;

  /// No description provided for @reply_matrix_table_title.
  ///
  /// In en, this message translates to:
  /// **'Who Replies to Whom'**
  String get reply_matrix_table_title;

  /// No description provided for @reply_matrix_table_in_degree.
  ///
  /// In en, this message translates to:
  /// **'In-degree (Replies Received)'**
  String get reply_matrix_table_in_degree;

  /// No description provided for @reply_matrix_table_copy_button.
  ///
  /// In en, this message translates to:
  /// **'Copy Reply Table'**
  String get reply_matrix_table_copy_button;

  /// No description provided for @display_options_dialog_language_selector_title.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get display_options_dialog_language_selector_title;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @language_spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get language_spanish;

  /// No description provided for @response_time_chart_title.
  ///
  /// In en, this message translates to:
  /// **'Average Response Time'**
  String get response_time_chart_title;

  /// No description provided for @sentiment_bar_chart_title.
  ///
  /// In en, this message translates to:
  /// **'Sentiment Analysis'**
  String get sentiment_bar_chart_title;

  /// No description provided for @sentiment_bar_chart_positive_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Positive: {percent}%'**
  String sentiment_bar_chart_positive_tooltip(Object percent);

  /// No description provided for @sentiment_bar_chart_negative_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Negative: {percent}%'**
  String sentiment_bar_chart_negative_tooltip(Object percent);

  /// No description provided for @sentiment_bar_chart_neutral_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Neutral: {percent}%'**
  String sentiment_bar_chart_neutral_tooltip(Object percent);

  /// No description provided for @sentiment_bar_chart_positive_legend.
  ///
  /// In en, this message translates to:
  /// **'{count} positive'**
  String sentiment_bar_chart_positive_legend(Object count);

  /// No description provided for @sentiment_bar_chart_negative_legend.
  ///
  /// In en, this message translates to:
  /// **'{count} negative'**
  String sentiment_bar_chart_negative_legend(Object count);

  /// No description provided for @sentiment_bar_chart_neutral_legend.
  ///
  /// In en, this message translates to:
  /// **'{count} neutral'**
  String sentiment_bar_chart_neutral_legend(Object count);

  /// No description provided for @sentiment_heatmap_title.
  ///
  /// In en, this message translates to:
  /// **'Sentiment Trend ({year})'**
  String sentiment_heatmap_title(Object year);

  /// No description provided for @sentiment_heatmap_no_data.
  ///
  /// In en, this message translates to:
  /// **'No sentiment data for this year.'**
  String get sentiment_heatmap_no_data;

  /// No description provided for @sentiment_heatmap_positive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get sentiment_heatmap_positive;

  /// No description provided for @sentiment_heatmap_negative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get sentiment_heatmap_negative;

  /// No description provided for @sentiment_heatmap_neutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get sentiment_heatmap_neutral;

  /// No description provided for @sentiment_heatmap_snackbar_content.
  ///
  /// In en, this message translates to:
  /// **'{sentimentText} sentiment ({score}) on {date}.'**
  String sentiment_heatmap_snackbar_content(Object date, Object score, Object sentimentText);

  /// No description provided for @sentiment_heatmap_close_button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get sentiment_heatmap_close_button;

  /// No description provided for @starters_enders_view_title.
  ///
  /// In en, this message translates to:
  /// **'Conversation Starters & Enders'**
  String get starters_enders_view_title;

  /// No description provided for @starters_enders_view_starters_title.
  ///
  /// In en, this message translates to:
  /// **'Starters'**
  String get starters_enders_view_starters_title;

  /// No description provided for @starters_enders_view_enders_title.
  ///
  /// In en, this message translates to:
  /// **'Enders'**
  String get starters_enders_view_enders_title;

  /// No description provided for @temporal_analysis_view_title.
  ///
  /// In en, this message translates to:
  /// **'Temporal Analysis'**
  String get temporal_analysis_view_title;

  /// No description provided for @threshold_slider_title.
  ///
  /// In en, this message translates to:
  /// **'Conversation Threshold'**
  String get threshold_slider_title;

  /// No description provided for @threshold_slider_description.
  ///
  /// In en, this message translates to:
  /// **'Detected natural threshold: {duration}. Use the slider to adjust.'**
  String threshold_slider_description(Object duration);

  /// No description provided for @equity_gauges_title.
  ///
  /// In en, this message translates to:
  /// **'Participation Equity'**
  String get equity_gauges_title;

  /// No description provided for @equity_gauges_speaking_equity.
  ///
  /// In en, this message translates to:
  /// **'Speaking Equity'**
  String get equity_gauges_speaking_equity;

  /// No description provided for @equity_gauges_listening_equity.
  ///
  /// In en, this message translates to:
  /// **'Listening Equity'**
  String get equity_gauges_listening_equity;

  /// No description provided for @equity_gauges_description.
  ///
  /// In en, this message translates to:
  /// **'(0 = perfect equality, 1 = perfect inequality)'**
  String get equity_gauges_description;

  /// No description provided for @influence_podium_title.
  ///
  /// In en, this message translates to:
  /// **'Influence Podium'**
  String get influence_podium_title;

  /// No description provided for @interactive_network_graph_title.
  ///
  /// In en, this message translates to:
  /// **'Communication Network'**
  String get interactive_network_graph_title;

  /// No description provided for @key_relationships_title.
  ///
  /// In en, this message translates to:
  /// **'Key Relationships'**
  String get key_relationships_title;

  /// No description provided for @key_relationships_strong_pair.
  ///
  /// In en, this message translates to:
  /// **'Strong Pair'**
  String get key_relationships_strong_pair;

  /// No description provided for @key_relationships_monologue.
  ///
  /// In en, this message translates to:
  /// **'Monologue'**
  String get key_relationships_monologue;

  /// No description provided for @key_relationships_reciprocity.
  ///
  /// In en, this message translates to:
  /// **'Reciprocity: {reciprocity}'**
  String key_relationships_reciprocity(Object reciprocity);

  /// No description provided for @markov_simulation_view_button.
  ///
  /// In en, this message translates to:
  /// **'🔮 Simulate conversation'**
  String get markov_simulation_view_button;

  /// No description provided for @markov_simulation_view_length.
  ///
  /// In en, this message translates to:
  /// **'Length: {length} messages'**
  String markov_simulation_view_length(Object length);

  /// No description provided for @markov_simulation_view_no_simulation.
  ///
  /// In en, this message translates to:
  /// **'No simulation generated yet'**
  String get markov_simulation_view_no_simulation;

  /// No description provided for @top_brokers_cards_title.
  ///
  /// In en, this message translates to:
  /// **'Top Brokers'**
  String get top_brokers_cards_title;

  /// No description provided for @top_brokers_cards_no_brokers_message.
  ///
  /// In en, this message translates to:
  /// **'No significant brokers found in this conversation. This suggests that communication is linear (A -> B -> C) or dispersed, without a single crucial \"bridge\" connecting other pairs of users.'**
  String get top_brokers_cards_no_brokers_message;

  /// No description provided for @top_brokers_cards_broker_score.
  ///
  /// In en, this message translates to:
  /// **'Broker Score: {score}'**
  String top_brokers_cards_broker_score(Object score);

  /// No description provided for @top_brokers_cards_broker_description.
  ///
  /// In en, this message translates to:
  /// **'This user acts as a key bridge between other participants.'**
  String get top_brokers_cards_broker_description;

  /// No description provided for @top_transitions_view_title.
  ///
  /// In en, this message translates to:
  /// **'Who Replies to Whom?'**
  String get top_transitions_view_title;

  /// No description provided for @top_transitions_view_description.
  ///
  /// In en, this message translates to:
  /// **'Top {topCount} of {maxTransitions} transitions'**
  String top_transitions_view_description(Object maxTransitions, Object topCount);

  /// No description provided for @log_title.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get log_title;

  /// No description provided for @log_empty.
  ///
  /// In en, this message translates to:
  /// **'(empty)'**
  String get log_empty;

  /// No description provided for @info_wrapper_info_button.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info_wrapper_info_button;

  /// No description provided for @export_button_label.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export_button_label;

  /// Label for exporting data as CSV
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get export_csv;

  /// Label for exporting data as JSON
  ///
  /// In en, this message translates to:
  /// **'Export as JSON'**
  String get export_json;

  /// Label for exporting data as YAML
  ///
  /// In en, this message translates to:
  /// **'Export as YAML'**
  String get export_yaml;

  /// Label for exporting data as TOON format
  ///
  /// In en, this message translates to:
  /// **'Export as TOON'**
  String get export_toon;

  /// Label for exporting the analysis as an image
  ///
  /// In en, this message translates to:
  /// **'Export Image'**
  String get export_image;

  /// Message shown when a file is exported with its path
  ///
  /// In en, this message translates to:
  /// **'Exported to: {path}'**
  String export_exported_to(Object path);

  /// Message shown when an image is saved
  ///
  /// In en, this message translates to:
  /// **'Image saved to: {path}'**
  String export_saved_image(Object path);

  /// Error message when no directory is available to save files
  ///
  /// In en, this message translates to:
  /// **'Could not find a suitable directory to save the file.'**
  String get export_error_no_directory;

  /// Generic export error message
  ///
  /// In en, this message translates to:
  /// **'Error exporting: {error}'**
  String export_error_exporting(Object error);

  /// Message shown when user tries to export without structured data
  ///
  /// In en, this message translates to:
  /// **'No structured data provided to export.'**
  String get export_no_data_provided;

  /// Label for action to open the folder containing the exported file
  ///
  /// In en, this message translates to:
  /// **'Open Folder'**
  String get open_folder_action;

  /// Default share message when sharing an exported image
  ///
  /// In en, this message translates to:
  /// **'Check out my chat analysis!'**
  String get share_message_analysis;

  /// Text for share action when exporting data
  ///
  /// In en, this message translates to:
  /// **'Exported {file}'**
  String share_exported_text(Object file);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
