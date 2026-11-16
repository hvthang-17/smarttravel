import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarttravel_mobile/features/auth/data/models/user_model.dart';
import 'package:smarttravel_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/auth/presentation/screens/password_reset_dialog.dart';
import 'package:smarttravel_mobile/features/profile/presentation/widgets/delete_account_dialog.dart';

class AccountDialogRepository extends AuthRepository {
  AccountDialogRepository() : super(Dio(), const FlutterSecureStorage());

  String? requestedEmail;
  String? resetCode;
  String? deletionToken;
  bool offline = false;

  @override
  Future<void> requestPasswordReset(String email) async {
    if (offline) throw Exception('Không thể kết nối máy chủ');
    requestedEmail = email;
  }

  @override
  Future<void> resetPassword(String code, String password) async {
    resetCode = code;
  }

  @override
  Future<UserState> login(String email, String password) async =>
      UserState(id: 1, email: email, role: 'ROLE_USER', token: 'user-token');

  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> clearAccountSettings(int id) async {}

  @override
  Future<void> deleteAccount(String password, String token) async {
    deletionToken = token;
  }
}

void main() {
  testWidgets('reset dialog reports connection failure and submits email then code', (tester) async {
    final repo = AccountDialogRepository()..offline = true;
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: Builder(builder: (context) => TextButton(
        onPressed: () => showDialog<bool>(context: context,
          builder: (_) => PasswordResetDialog(repository: repo, email: 'traveler@example.test')),
        child: const Text('Mở đặt lại'),
      )),
    )));
    await tester.tap(find.text('Mở đặt lại'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gửi mã'));
    await tester.pumpAndSettle();
    expect(find.text('Không thể kết nối máy chủ'), findsOneWidget);
    expect(find.text('Mã trong email'), findsNothing);
    repo.offline = false;
    await tester.tap(find.text('Gửi mã'));
    await tester.pumpAndSettle();
    expect(repo.requestedEmail, 'traveler@example.test');
    final code = 'a' * 43;
    await tester.enterText(find.byType(TextField).at(0), code);
    await tester.enterText(find.byType(TextField).at(1), 'NewPassword123');
    await tester.enterText(find.byType(TextField).at(2), 'NewPassword123');
    await tester.tap(find.text('Đổi mật khẩu'));
    await tester.pumpAndSettle();
    expect(repo.resetCode, code);
    expect(find.byType(PasswordResetDialog), findsNothing);
  });

  testWidgets('deletion requires confirmation and clears the account session', (tester) async {
    final repo = AccountDialogRepository();
    final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(container.dispose);
    await container.read(authNotifierProvider.notifier).login('traveler@example.test', 'password');
    await tester.pumpWidget(UncontrolledProviderScope(container: container,
      child: MaterialApp(home: Scaffold(body: Builder(builder: (context) => TextButton(
        onPressed: () => showDialog<bool>(context: context, builder: (_) => const DeleteAccountDialog()),
        child: const Text('Mở xóa tài khoản'),
      )))),
    ));
    await tester.tap(find.text('Mở xóa tài khoản'));
    await tester.pumpAndSettle();
    final delete = find.widgetWithText(FilledButton, 'Xóa tài khoản');
    expect(tester.widget<FilledButton>(delete).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'CurrentPassword123');
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.tap(delete);
    await tester.pumpAndSettle();
    expect(repo.deletionToken, 'user-token');
    expect(container.read(authNotifierProvider).isAuthenticated, isFalse);
    expect(find.byType(DeleteAccountDialog), findsNothing);
  });
}
