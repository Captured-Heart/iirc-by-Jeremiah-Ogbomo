import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';
import '../utils.dart';

void main() {
  group('App', () {
    final AccountEntity dummyAccount = AuthMockImpl.generateAccount();
    final UserEntity dummyUser = UsersMockImpl.user;

    setUpAll(() {
      registerFallbackValue(dummyAccount);
      registerFallbackValue(FakeUpdateUserData());
    });

    testWidgets('should login and navigate to onboarding page', (WidgetTester tester) async {
      final Finder onboardingPage = find.byType(OnboardingPage);
      final Finder menuPage = find.byType(MenuPage);

      when(() => mockUseCases.fetchUserUseCase.call(any())).thenAnswer((_) async => dummyUser);
      when(mockUseCases.signInUseCase.call).thenAnswer((_) async => dummyAccount);
      when(() => mockUseCases.updateUserUseCase.call(any())).thenAnswer((_) async => true);

      addTearDown(mockUseCases.reset);

      await tester.pumpWidget(
        createApp(
          registry: createRegistry().withMockedUseCases(),
          includeMaterial: false,
        ),
      );

      await tester.pump();

      expect(onboardingPage, findsOneWidget);
      expect(menuPage, findsNothing);

      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('TESTING')), findsOneWidget);
      expect(menuPage, findsOneWidget);
      expect(find.byType(ItemsPage).descendantOf(menuPage), findsOneWidget);
      expect(find.byType(CalendarPage).descendantOf(menuPage), findsOneWidget);
      expect(find.byType(InsightsPage).descendantOf(menuPage), findsOneWidget);
      expect(find.byType(MorePage).descendantOf(menuPage), findsOneWidget);
    });
  });
}
