import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../pages/splash/splash_page.dart';
import '../../pages/user_selection/user_selection_page.dart';
import '../../pages/register/register_page.dart';
import '../../pages/login/login_page.dart';
import '../../pages/phone_verification/phone_verification_page.dart';
import '../../pages/pending_review/pending_review_page.dart';
import '../../pages/forgot_password/forgot_password_page.dart';
import '../../pages/forgot_password/email_sent_page.dart';
import '../../pages/forgot_password/reset_password_page.dart';
import '../../pages/forgot_password/password_updated_page.dart';
import '../../pages/professional_validation/step1_professional_data_page.dart';
import '../../pages/professional_validation/step2_documents_page.dart';
import '../../pages/professional_validation/step3_availability_page.dart';
import '../../pages/professional_validation/validation_status_page.dart';
import '../../pages/profile/profile_page.dart';
import '../../pages/profile/basic_data_page.dart';
import '../../pages/profile/settings_page.dart';
import '../../pages/profile/schedule_page.dart';
import '../../pages/profile/about_page.dart';
import '../../pages/appointment/appointments_page.dart';
import '../../pages/appointment/pre_consultation_page.dart';
import '../../pages/appointment/live_consultation_page.dart' as doctor_appointment;
import '../../pages/appointment/prescription_products_page.dart';
import '../../pages/appointment/prescription_details_page.dart';
import '../../pages/appointment/finish_appointment_page.dart';
import '../../pages/appointment/appointment_details_page.dart';
import '../../pages/financial/financial_page.dart';
import '../../pages/financial/financial_history_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/home/catalog_page.dart';
import '../../pages/home/product_details_page.dart';
import '../../pages/patient/account/account_page.dart';
import '../../pages/patient/account/basic_data_page.dart';
import '../../pages/patient/account/settings_page.dart';
import '../../pages/patient/account/anvisa_page.dart';
import '../../pages/patient/account/about_page.dart';
import '../../pages/patient/orders/orders_history_page.dart';
import '../../pages/patient/orders/order_details_page.dart';
import '../../pages/patient/orders/new_order_step1_page.dart';
import '../../pages/patient/orders/new_order_step2_page.dart';
import '../../pages/patient/orders/new_order_step3_page.dart';
import '../../pages/patient/orders/new_order_step4_page.dart';
import '../../pages/patient/consultations/consultations_page.dart';
import '../../pages/patient/consultations/consultation_details_page.dart';
import '../../pages/patient/consultations/live_consultation_page.dart';
import '../../pages/patient/consultations/finish_consultation_page.dart';
import '../../pages/patient/consultations/new_consultation_step1_page.dart';
import '../../pages/patient/consultations/new_consultation_step2_page.dart';
import '../../pages/patient/consultations/new_consultation_step3_page.dart';
import '../../pages/patient/consultations/new_consultation_step4_page.dart';
import '../../pages/patient/prescriptions/prescriptions_page.dart';
import '../../pages/patient/home/patient_home_page.dart';
import '../../pages/patient/home/catalog_page.dart' as patient_catalog;
import '../../pages/patient/home/product_details_page.dart' as patient_product;

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/user-selection',
        name: 'user-selection',
        builder: (context, state) => const UserSelectionPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) {
          final userType = state.uri.queryParameters['type'];
          return RegisterPage(userType: userType);
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/phone-verification',
        name: 'phone-verification',
        builder: (context, state) {
          final phoneNumber = state.uri.queryParameters['phone'];
          return PhoneVerificationPage(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: '/pending-review',
        name: 'pending-review',
        builder: (context, state) => const PendingReviewPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
        routes: [
          GoRoute(
            path: 'email-sent',
            name: 'email-sent',
            builder: (context, state) => const EmailSentPage(),
          ),
          GoRoute(
            path: 'reset',
            name: 'reset-password',
            builder: (context, state) => const ResetPasswordPage(),
          ),
          GoRoute(
            path: 'password-updated',
            name: 'password-updated',
            builder: (context, state) => const PasswordUpdatedPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/professional-validation',
        name: 'professional-validation',
        redirect: (context, state) => '/professional-validation/step1-professional-data',
        routes: [
          GoRoute(
            path: 'step1-professional-data',
            name: 'step1-professional-data',
            builder: (context, state) => const Step1ProfessionalDataPage(),
          ),
          GoRoute(
            path: 'step2-documents',
            name: 'step2-documents',
            builder: (context, state) => const Step2DocumentsPage(),
          ),
          GoRoute(
            path: 'step3-availability',
            name: 'step3-availability',
            builder: (context, state) => const Step3AvailabilityPage(),
          ),
          GoRoute(
            path: 'status',
            name: 'validation-status',
            builder: (context, state) => const ValidationStatusPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
        routes: [
          GoRoute(
            path: 'basic-data',
            name: 'basic-data',
            builder: (context, state) => const BasicDataPage(),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: 'schedule',
            name: 'schedule',
            builder: (context, state) => const SchedulePage(),
          ),
          GoRoute(
            path: 'about',
            name: 'about',
            builder: (context, state) => const AboutPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/appointment',
        name: 'appointment',
        builder: (context, state) => const AppointmentsPage(),
        routes: [
          GoRoute(
            path: 'pre-consultation',
            name: 'pre-consultation',
            builder: (context, state) => const PreConsultationPage(),
          ),
          GoRoute(
            path: 'live-consultation',
            name: 'live-consultation',
            builder: (context, state) => const doctor_appointment.LiveConsultationPage(),
          ),
          GoRoute(
            path: 'prescription-products',
            name: 'prescription-products',
            builder: (context, state) => const PrescriptionProductsPage(),
          ),
          GoRoute(
            path: 'prescription-details',
            name: 'prescription-details',
            builder: (context, state) => const PrescriptionDetailsPage(),
          ),
          GoRoute(
            path: 'finish',
            name: 'finish-appointment',
            builder: (context, state) => const FinishAppointmentPage(),
          ),
          GoRoute(
            path: 'details',
            name: 'appointment-details',
            builder: (context, state) => const AppointmentDetailsPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/financial',
        name: 'financial',
        builder: (context, state) => const FinancialPage(),
        routes: [
          GoRoute(
            path: 'history',
            name: 'financial-history',
            builder: (context, state) => const FinancialHistoryPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/catalog',
        name: 'catalog',
        builder: (context, state) => const CatalogPage(),
        routes: [
          GoRoute(
            path: 'product-details',
            name: 'product-details',
            builder: (context, state) => const ProductDetailsPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/patient/account',
        name: 'patient-account',
        builder: (context, state) => const PatientAccountPage(),
        routes: [
          GoRoute(
            path: 'basic-data',
            name: 'patient-basic-data',
            builder: (context, state) => const PatientBasicDataPage(),
          ),
          GoRoute(
            path: 'anvisa',
            name: 'patient-anvisa',
            builder: (context, state) => const PatientAnvisaPage(),
          ),
          GoRoute(
            path: 'settings',
            name: 'patient-settings',
            builder: (context, state) => const PatientSettingsPage(),
          ),
          GoRoute(
            path: 'about',
            name: 'patient-about',
            builder: (context, state) => const PatientAboutPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/patient/orders',
        name: 'patient-orders',
        builder: (context, state) => const OrdersHistoryPage(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'patient-order-details',
            builder: (context, state) {
              final orderId = state.pathParameters['id'] ?? '';
              return OrderDetailsPage(orderId: orderId);
            },
          ),
          GoRoute(
            path: 'new',
            name: 'patient-new-order',
            routes: [
              GoRoute(
                path: 'step1',
                name: 'patient-new-order-step1',
                builder: (context, state) => const NewOrderStep1Page(),
              ),
              GoRoute(
                path: 'step2',
                name: 'patient-new-order-step2',
                builder: (context, state) => const NewOrderStep2Page(),
              ),
              GoRoute(
                path: 'step3',
                name: 'patient-new-order-step3',
                builder: (context, state) => const NewOrderStep3Page(),
              ),
              GoRoute(
                path: 'step4',
                name: 'patient-new-order-step4',
                builder: (context, state) => const NewOrderStep4Page(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/patient/consultations',
        name: 'patient-consultations',
        builder: (context, state) => const ConsultationsPage(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'patient-consultation-details',
            builder: (context, state) {
              final consultationId = state.pathParameters['id'] ?? '';
              return ConsultationDetailsPage(consultationId: consultationId);
            },
          ),
          GoRoute(
            path: 'live/:id',
            name: 'patient-live-consultation',
            builder: (context, state) {
              final consultationId = state.pathParameters['id'] ?? '';
              return LiveConsultationPage(consultationId: consultationId);
            },
          ),
          GoRoute(
            path: 'finish/:id',
            name: 'patient-finish-consultation',
            builder: (context, state) {
              final consultationId = state.pathParameters['id'] ?? '';
              return FinishConsultationPage(consultationId: consultationId);
            },
          ),
          GoRoute(
            path: 'new',
            name: 'patient-new-consultation',
            routes: [
              GoRoute(
                path: 'step1',
                name: 'patient-new-consultation-step1',
                builder: (context, state) => const NewConsultationStep1Page(),
              ),
              GoRoute(
                path: 'step2',
                name: 'patient-new-consultation-step2',
                builder: (context, state) => const NewConsultationStep2Page(),
              ),
              GoRoute(
                path: 'step3',
                name: 'patient-new-consultation-step3',
                builder: (context, state) => const NewConsultationStep3Page(),
              ),
              GoRoute(
                path: 'step4',
                name: 'patient-new-consultation-step4',
                builder: (context, state) => const NewConsultationStep4Page(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/patient/prescriptions',
        name: 'patient-prescriptions',
        builder: (context, state) => const PrescriptionsPage(),
      ),
      GoRoute(
        path: '/patient/home',
        name: 'patient-home',
        builder: (context, state) => const PatientHomePage(),
      ),
      GoRoute(
        path: '/patient/catalog',
        name: 'patient-catalog',
        builder: (context, state) => const patient_catalog.PatientCatalogPage(),
        routes: [
          GoRoute(
            path: 'product-details/:id',
            name: 'patient-product-details',
            builder: (context, state) {
              final productId = state.pathParameters['id'] ?? '';
              return patient_product.PatientProductDetailsPage(productId: productId);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página não encontrada: ${state.uri}'),
      ),
    ),
  );
}

