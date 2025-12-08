// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get name => 'Chat Analyzer';

  @override
  String get home_action_tooltip => 'Ver Chat Completo';

  @override
  String get home_action_display => 'Opciones de Visualización';

  @override
  String get home_action_reset => 'Reiniciar Análisis';

  @override
  String get home_action_logs => 'Ver Registros';

  @override
  String get initial_view_message_1 => 'Arrastra y suelta tu archivo .txt aquí';

  @override
  String get initial_view_message_2 => 'o';

  @override
  String get initial_view_message_3 => 'Cargar archivo de chat (.txt)';

  @override
  String get initial_view_credits_button => 'Créditos';

  @override
  String get cat_phrase_1 => '¡Miau!';

  @override
  String get cat_phrase_2 => 'Purr.';

  @override
  String get cat_phrase_3 => '¡Nyan!';

  @override
  String get cat_phrase_4 => 'Analizando chats...';

  @override
  String get cat_phrase_5 => 'Vi algo que no debí ver...';

  @override
  String get cat_phrase_6 => 'Gatito trabajando, no molestar...';

  @override
  String get cat_phrase_7 => 'Calculando los chismes... esto tomará un momento.';

  @override
  String get cat_phrase_8 => 'Contando emojis... 😼';

  @override
  String get cat_phrase_9 => 'Conspirando para dominar el mundo... o solo el chat.';

  @override
  String get cat_phrase_10 => 'Limpiando las patitas... ya casi termino.';

  @override
  String get credits_modal_title => 'Créditos';

  @override
  String get credits_modal_intro => 'Desarrollado por xeland314.';

  @override
  String get credits_modal_my_name => '(Christopher Villamarin), 2025.';

  @override
  String get credits_modal_github_profile => 'Perfil de GitHub';

  @override
  String get credits_modal_portfolio => 'Portafolio';

  @override
  String get credits_modal_donations => 'Donaciones';

  @override
  String get credits_modal_close_button => 'Cerrar';

  @override
  String get credits_modal_buy_me_a_cookie_semantic_label => 'Cómprame una galleta en https://www.buymeacoffee.com/xeland314';

  @override
  String get credits_modal_buy_me_a_coffee_semantic_label => 'Cómprame un café en ko-fi.com/C0C41DCI4T';

  @override
  String get disclaimer_modal_text => 'Esta app analiza solo chats que exportas manualmente de WhatsApp.';

  @override
  String get disclaimer_modal_privacy_notice_title => 'Aviso de Privacidad';

  @override
  String get disclaimer_modal_privacy_notice_content => 'Esta aplicación procesa únicamente chats que tú exportas manualmente desde WhatsApp. No accede a tu cuenta ni recopila información automáticamente. Todos los datos se analizan localmente en tu dispositivo y se anonimiza la información sensible para proteger la privacidad de terceros.';

  @override
  String get disclaimer_modal_privacy_notice_close_button => 'Cerrar';

  @override
  String get disclaimer_modal_privacy_notice_touch_to_view => 'Toca aquí para ver el aviso completo';

  @override
  String get display_options_dialog_title => 'Opciones de Visualización';

  @override
  String get display_options_dialog_number_of_words_to_display => 'Número de palabras a mostrar';

  @override
  String get display_options_dialog_ignored_words => 'Palabras ignoradas';

  @override
  String get display_options_dialog_add_a_word_to_ignore => 'Añadir una palabra a ignorar';

  @override
  String get display_options_dialog_cancel_button => 'Cancelar';

  @override
  String get display_options_dialog_save_button => 'Guardar';

  @override
  String get loading_view_pixel_cat_semantic_label => 'Gato pixelado trabajando';

  @override
  String get chat_date_selector_full_chat => 'Chat Completo';

  @override
  String get chat_message_list_no_messages => 'No hay mensajes en esta fecha.';

  @override
  String activity_heatmap_message_activity(Object year) {
    return 'Actividad de Mensajes ($year)';
  }

  @override
  String get activity_heatmap_no_message_activity => 'No hay actividad de mensajes para este año.';

  @override
  String activity_heatmap_messages_on_date(Object count, Object date) {
    return '$count mensajes en $date.';
  }

  @override
  String get activity_heatmap_close_button => 'Cerrar';

  @override
  String get advanced_analysis_view_title => 'Análisis de Interacción Avanzado';

  @override
  String get advanced_analysis_view_reply_matrix_title => 'Matriz de Respuestas';

  @override
  String get advanced_analysis_view_reply_matrix_info => 'Esta tabla muestra el número de respuestas que cada participante recibió de otros.';

  @override
  String get advanced_analysis_view_markov_chain_title => 'Cadena de Markov';

  @override
  String get advanced_analysis_view_markov_chain_info => 'Esta tabla muestra la probabilidad de que un participante responda a otro.';

  @override
  String get analysis_result_view_advanced_analysis_title => 'Análisis Avanzado';

  @override
  String get analysis_result_view_view_advanced_analysis_button => 'Ver Análisis Avanzado';

  @override
  String get analysis_result_view_chat_analysis_report_filename => 'reporte_analisis_chat';

  @override
  String get composite_affinity_view_title => 'Afinidad Compuesta (Directa + Indirecta)';

  @override
  String get composite_affinity_view_from_to => 'Origen \\ Destino';

  @override
  String get dashboard_view_title => 'Dashboard';

  @override
  String get emitter_similarity_view_title => 'Similitud de Emisor (Perfiles de Comunicación Similares)';

  @override
  String get emitter_similarity_view_participant_participant => 'Participante \\ Participante';

  @override
  String get frequency_list_view_no_data => 'No se encontraron datos.';

  @override
  String get hourly_activity_chart_title => 'Horas más Activas';

  @override
  String hourly_activity_chart_hour(Object hour) {
    return '${hour}h';
  }

  @override
  String hourly_activity_chart_messages_tooltip(Object count) {
    return '$count mensajes';
  }

  @override
  String get markov_chain_view_matrix_copied_snackbar => 'Matriz copiada al portapapeles (formato CSV/TSV)';

  @override
  String get markov_chain_view_title => 'Cadena de Markov - Probabilidades de Transición';

  @override
  String get markov_chain_view_from_to => 'Origen \\ Destino';

  @override
  String get markov_chain_view_copy_matrix_button => 'Copiar Matriz de Transición';

  @override
  String get markov_chain_view_export_matrix_button => 'Exportar matriz de transición';

  @override
  String get matrix_squared_view_title => 'Influencia Indirecta Normalizada (M²)';

  @override
  String get matrix_squared_view_from_to => 'Origen \\ Destino';

  @override
  String participant_stats_view_subtitle(Object messageCount, Object multimediaCount) {
    return '$messageCount mensajes, $multimediaCount archivos multimedia';
  }

  @override
  String get participant_stats_view_most_common_words => 'Palabras más Comunes';

  @override
  String get participant_stats_view_most_common_emojis => 'Emojis más Comunes';

  @override
  String get receiver_similarity_view_title => 'Similitud de Receptor (Roles Similares)';

  @override
  String get receiver_similarity_view_participant_participant => 'Participante \\ Participante';

  @override
  String get reply_matrix_table_copied_snackbar => 'Tabla de respuestas copiada al portapapeles (formato TSV)';

  @override
  String get reply_matrix_table_replier_to => 'Respondedor \\ A';

  @override
  String get reply_matrix_table_out_degree => 'Grado de Salida (Respuestas Enviadas)';

  @override
  String get reply_matrix_table_balance => 'Balance (Salida - Entrada)';

  @override
  String get reply_matrix_table_title => 'Quién Responde a Quién';

  @override
  String get reply_matrix_table_in_degree => 'Grado de Entrada (Respuestas Recibidas)';

  @override
  String get reply_matrix_table_copy_button => 'Copiar Tabla de Respuestas';

  @override
  String get display_options_dialog_language_selector_title => 'Idioma';

  @override
  String get language_english => 'Inglés';

  @override
  String get language_spanish => 'Español';

  @override
  String get response_time_chart_title => 'Tiempo de Respuesta Promedio';

  @override
  String get sentiment_bar_chart_title => 'Análisis de Sentimiento';

  @override
  String sentiment_bar_chart_positive_tooltip(Object percent) {
    return 'Positivo: $percent%';
  }

  @override
  String sentiment_bar_chart_negative_tooltip(Object percent) {
    return 'Negativo: $percent%';
  }

  @override
  String sentiment_bar_chart_neutral_tooltip(Object percent) {
    return 'Neutral: $percent%';
  }

  @override
  String sentiment_bar_chart_positive_legend(Object count) {
    return '$count positivo';
  }

  @override
  String sentiment_bar_chart_negative_legend(Object count) {
    return '$count negativo';
  }

  @override
  String sentiment_bar_chart_neutral_legend(Object count) {
    return '$count neutral';
  }

  @override
  String sentiment_heatmap_title(Object year) {
    return 'Tendencia de Sentimiento ($year)';
  }

  @override
  String get sentiment_heatmap_no_data => 'No hay datos de sentimiento para este año.';

  @override
  String get sentiment_heatmap_positive => 'Positivo';

  @override
  String get sentiment_heatmap_negative => 'Negativo';

  @override
  String get sentiment_heatmap_neutral => 'Neutral';

  @override
  String sentiment_heatmap_snackbar_content(Object date, Object score, Object sentimentText) {
    return 'Sentimiento $sentimentText ($score) en $date.';
  }

  @override
  String get sentiment_heatmap_close_button => 'Cerrar';

  @override
  String get starters_enders_view_title => 'Iniciadores y Finalizadores de Conversación';

  @override
  String get starters_enders_view_starters_title => 'Iniciadores';

  @override
  String get starters_enders_view_enders_title => 'Finalizadores';

  @override
  String get temporal_analysis_view_title => 'Análisis Temporal';

  @override
  String get threshold_slider_title => 'Umbral de Conversación';

  @override
  String threshold_slider_description(Object duration) {
    return 'Umbral natural detectado: $duration. Usa el deslizador para ajustar.';
  }

  @override
  String get equity_gauges_title => 'Equidad de Participación';

  @override
  String get equity_gauges_speaking_equity => 'Equidad al Hablar';

  @override
  String get equity_gauges_listening_equity => 'Equidad al Escuchar';

  @override
  String get equity_gauges_description => '(0 = igualdad perfecta, 1 = desigualdad perfecta)';

  @override
  String get influence_podium_title => 'Podio de Influencia';

  @override
  String get interactive_network_graph_title => 'Red de Comunicación';

  @override
  String get key_relationships_title => 'Relaciones Clave';

  @override
  String get key_relationships_strong_pair => 'Par Fuerte';

  @override
  String get key_relationships_monologue => 'Monólogo';

  @override
  String key_relationships_reciprocity(Object reciprocity) {
    return 'Reciprocidad: $reciprocity';
  }

  @override
  String get markov_simulation_view_button => '🔮 Simular conversación';

  @override
  String markov_simulation_view_length(Object length) {
    return 'Longitud: $length mensajes';
  }

  @override
  String get markov_simulation_view_no_simulation => 'Aún no hay simulación generada';

  @override
  String get top_brokers_cards_title => 'Top Brokers';

  @override
  String get top_brokers_cards_no_brokers_message => 'No se encontraron brokers significativos en esta conversación. Esto sugiere que la comunicación es lineal (A -> B -> C) o dispersa, sin un único \"puente\" crucial que conecte a otros pares de usuarios.';

  @override
  String top_brokers_cards_broker_score(Object score) {
    return 'Puntuación de Broker: $score';
  }

  @override
  String get top_brokers_cards_broker_description => 'Este usuario actúa como un puente clave entre otros participantes.';

  @override
  String get top_transitions_view_title => '¿Quién responde a quién?';

  @override
  String top_transitions_view_description(Object maxTransitions, Object topCount) {
    return 'Top $topCount de $maxTransitions transiciones';
  }

  @override
  String get log_title => 'Registro';

  @override
  String get log_empty => '(vacío)';

  @override
  String get info_wrapper_info_button => 'Info';

  @override
  String get export_button_label => 'Exportar';

  @override
  String get export_csv => 'Exportar como CSV';

  @override
  String get export_json => 'Exportar como JSON';

  @override
  String get export_yaml => 'Exportar como YAML';

  @override
  String get export_toon => 'Exportar como TOON';

  @override
  String get export_image => 'Exportar Imagen';

  @override
  String export_exported_to(Object path) {
    return 'Exportado a: $path';
  }

  @override
  String export_saved_image(Object path) {
    return 'Imagen guardada en: $path';
  }

  @override
  String get export_error_no_directory => 'No se pudo encontrar un directorio adecuado para guardar el archivo.';

  @override
  String export_error_exporting(Object error) {
    return 'Error al exportar: $error';
  }

  @override
  String get export_no_data_provided => 'No se proporcionaron datos estructurados para exportar.';

  @override
  String get open_folder_action => 'Abrir carpeta';

  @override
  String get share_message_analysis => '¡Mira mi análisis de chat!';

  @override
  String share_exported_text(Object file) {
    return 'Exportado $file';
  }
}
