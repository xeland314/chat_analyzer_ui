import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:chat_analyzer_ui/ui/chat/chat_date_selector.dart';
import 'package:chat_analyzer_ui/l10n/app_localizations.dart';

void main() {
  group('ChatDateSelector', () {
    testWidgets('muestra "Full Chat" cuando la lista de fechas está vacía', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          // 1. Proporcionar las delegadas de localización
          localizationsDelegates: const [
            AppLocalizations.delegate, // Tu delegado
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // 2. Definir los idiomas soportados (para que el delegado sepa qué cargar)
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Scaffold(
            body: ChatDateSelector(
              dates: [],
              selected: DateTime(2023, 1, 1),
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // 🚨 Paso clave: Obtener el contexto después de pumpWidget()
      final context = tester.element(find.byType(ChatDateSelector));
      expect(
        find.text(AppLocalizations.of(context)!.chat_date_selector_full_chat),
        findsOneWidget,
      );
      expect(find.byType(DropdownButton<DateTime>), findsNothing);
    });

    testWidgets('muestra DropdownButton con fechas cuando hay fechas', (
      WidgetTester tester,
    ) async {
      final dates = [DateTime(2023, 5, 20), DateTime(2023, 5, 21)];

      DateTime? selectedDate = dates.first;

      await tester.pumpWidget(
        MaterialApp(
          // 1. Proporcionar las delegadas de localización
          localizationsDelegates: const [
            AppLocalizations.delegate, // Tu delegado
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // 2. Definir los idiomas soportados (para que el delegado sepa qué cargar)
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Scaffold(
            body: ChatDateSelector(
              dates: dates,
              selected: selectedDate,
              onChanged: (date) {
                selectedDate = date;
              },
            ),
          ),
        ),
      );

      // El dropdown existe
      expect(find.byType(DropdownButton<DateTime>), findsOneWidget);

      // Muestra la fecha seleccionada
      expect(find.text(DateFormat.yMMMd().format(dates.first)), findsOneWidget);

      // Abrimos el dropdown
      await tester.tap(find.byType(DropdownButton<DateTime>));
      await tester.pumpAndSettle();

      // Debería mostrar ambas opciones
      expect(find.text(DateFormat.yMMMd().format(dates[0])), findsWidgets);
      expect(find.text(DateFormat.yMMMd().format(dates[1])), findsOneWidget);

      // Seleccionamos la segunda fecha
      await tester.tap(find.text(DateFormat.yMMMd().format(dates[1])));
      await tester.pumpAndSettle();

      expect(selectedDate, equals(dates[1]));
    });
  });
}
