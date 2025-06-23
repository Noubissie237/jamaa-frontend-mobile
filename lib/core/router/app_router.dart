import 'package:go_router/go_router.dart';
import 'package:jamaa_frontend_mobile/core/models/bank.dart';
import 'package:jamaa_frontend_mobile/presentation/screens/auth/forgot_password.dart';
import 'package:jamaa_frontend_mobile/presentation/screens/auth/pin_login_screen.dart';
import 'package:jamaa_frontend_mobile/presentation/screens/auth/register_step1_screen.dart';
import 'package:jamaa_frontend_mobile/presentation/screens/auth/register_step2_screen.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/auth/pin_setup_screen.dart';
import '../../presentation/screens/transactions/transactions_screen.dart';
import '../../presentation/screens/transactions/transaction_detail_screen.dart';
import '../../presentation/screens/transfer/transfer_screen.dart';
import '../../presentation/screens/transfer/transfer_confirmation_screen.dart';
import '../../presentation/screens/payments/payments_screen.dart';
import '../../presentation/screens/payments/bill_payment_screen.dart';
import '../../presentation/screens/payments/qr_payment_screen.dart';
import '../../presentation/screens/withdraw_deposit/withdraw_screen.dart';
import '../../presentation/screens/withdraw_deposit/deposit_screen.dart';
import '../../presentation/screens/banks/banks_screen.dart';
import '../../presentation/screens/banks/add_bank_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/profile/security_settings_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/main/main_screen.dart';
import '../../presentation/screens/banks/bank_detail_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash & Onboarding
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication
      GoRoute(
        path: '/pin-login',
        name: 'pin-login',
        builder: (context, state) => const PinLoginScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterStep1Screen(),
      ),
      GoRoute(
        path: '/register-step2',
        name: 'register-step2',
        builder: (context, state) => RegisterStep2Screen(userData: state.extra as Map<String, dynamic>),
      ),

      GoRoute(
        path: '/pin-setup',
        name: 'pin-setup',
        builder: (context, state) => const PinSetupScreen(),
      ),

      // Main App
      GoRoute(
        path: '/main',
        name: 'main',
        builder: (context, state) => const MainScreen(),
        routes: [
          // Dashboard
          GoRoute(
            path: 'dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),

          // Transactions
          GoRoute(
            path: 'transactions',
            name: 'transactions',
            builder: (context, state) => const TransactionsScreen(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                name: 'transaction-detail',
                builder: (context, state) {
                  final transactionId = state.pathParameters['id']!;
                  return TransactionDetailScreen(transactionId: transactionId);
                },
              ),
            ],
          ),

          // Transfers
          GoRoute(
            path: 'transfer',
            name: 'transfer',
            builder: (context, state) => const TransferScreen(),
            routes: [
              GoRoute(
                path: 'confirmation',
                name: 'transfer-confirmation',
                builder: (context, state) {
                  final transferData = state.extra as Map<String, dynamic>;
                  return TransferConfirmationScreen(transferData: transferData);
                },
              ),
            ],
          ),

          // Payments
          GoRoute(
            path: 'payments',
            name: 'payments',
            builder: (context, state) => const PaymentsScreen(),
            routes: [
              GoRoute(
                path: 'bills',
                name: 'bill-payment',
                builder: (context, state) => const BillPaymentScreen(),
              ),
              GoRoute(
                path: 'qr',
                name: 'qr-payment',
                builder: (context, state) => const QRPaymentScreen(),
              ),
            ],
          ),

          // Withdraw & Deposit
          GoRoute(
            path: 'withdraw',
            name: 'withdraw',
            builder: (context, state) => const WithdrawScreen(),
          ),
          GoRoute(
            path: 'deposit',
            name: 'deposit',
            builder: (context, state) => const DepositScreen(),
          ),

          // Banks
          GoRoute(
            path: 'banks',
            name: 'banks',
            builder: (context, state) => const BanksScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-bank',
                builder: (context, state) => const AddBankScreen(),
              ),
              GoRoute(
                path: 'details',
                name: 'bank-details',
                builder: (context, state) => BankDetailsScreen(
                  bank: state.extra as Bank,
                ),
              ),
            ],
          ),

          // Profile
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'edit-profile',
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'security',
                name: 'security-settings',
                builder: (context, state) => const SecuritySettingsScreen(),
              ),
            ],
          ),

          GoRoute(
            path: 'forgot-password',
            name: 'forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(),
          ),

          // Notifications
          GoRoute(
            path: 'notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
        ],
      ),
    ],
  );
}