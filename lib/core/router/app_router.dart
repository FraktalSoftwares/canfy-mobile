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
import '../../pages/appointment/live_consultation_page.dart'
    as doctor_appointment;
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
import '../../pages/patient/orders/new_order_step5_page.dart';
import '../../pages/patient/orders/order_payment_success_page.dart';
import '../../pages/patient/consultations/consultations_page.dart';
import '../../pages/patient/consultations/consultation_details_page.dart';
import '../../pages/patient/consultations/live_consultation_page.dart';
import '../../pages/patient/consultations/finish_consultation_page.dart';
import '../../pages/patient/consultations/new_consultation_step1_page.dart';
import '../../pages/patient/consultations/new_consultation_step2_page.dart';
import '../../pages/patient/consultations/new_consultation_step3_page.dart';
import '../../pages/patient/consultations/new_consultation_step4_page.dart';
import '../../models/consultation/consultation_model.dart';
import '../../models/order/new_order_form_data.dart';
import '../../pages/patient/prescriptions/prescriptions_page.dart';
import '../../pages/patient/home/patient_home_page.dart';
import '../../pages/patient/home/catalog_page.dart' as patient_catalog;
import '../../pages/patient/home/product_details_page.dart' as patient_product;

/// Cria uma página sem transição de animação
CustomTransitionPage<void> _noTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        child,
  );
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) => _noTransitionPage(
          state: state,
          child: const SplashPage(),
        ),
      ),
      GoRoute(
        path: '/user-selection',
        name: 'user-selection',
        pageBuilder: (context, state) => _noTransitionPage(
          state: state,
          child: const UserSelectionPage(),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) {
          final userType = state.uri.queryParameters['type'];
          return _noTransitionPage(
            state: state,
            child: RegisterPage(userType: userType),
          );
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _noTransitionPage(
          state: state,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/phone-verification',
        name: 'phone-verification',
        pageBuilder: (context, state) {
          final phoneNumber = state.uri.queryParameters['phone'];
          return _noTransitionPage(
            state: state,
            child: PhoneVerificationPage(phoneNumber: phoneNumber),
          );
        },
      ),
      GoRoute(
        path: '/pending-review',
        name: 'pending-review',
        pageBuilder: (context, state) => _noTransitionPage(
          state: state,
          child: const PendingReviewPage(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        pageBuilder: (context, state) => _noTransitionPage(
          state: state,
          child: const ForgotPasswordPage(),
        ),
        routes: [
          GoRoute(
            path: 'email-sent',
            name: 'email-sent',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const EmailSentPage(),
            ),
          ),
          GoRoute(
            path: 'reset',
            name: 'reset-password',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const ResetPasswordPage(),
            ),
          ),
          GoRoute(
            path: 'password-updated',
            name: 'password-updated',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const PasswordUpdatedPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/professional-validation',
        name: 'professional-validation',
        redirect: (context, state) =>
            '/professional-validation/step1-professional-data',
        routes: [
          GoRoute(
            path: 'step1-professional-data',
            name: 'step1-professional-data',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const Step1ProfessionalDataPage(),
            ),
          ),
          GoRoute(
            path: 'step2-documents',
            name: 'step2-documents',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const Step2DocumentsPage(),
            ),
          ),
          GoRoute(
            path: 'step3-availability',
            name: 'step3-availability',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const Step3AvailabilityPage(),
            ),
          ),
          GoRoute(
            path: 'status',
            name: 'validation-status',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const ValidationStatusPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => _noTransitionPage(
          state: state,
          child: const ProfilePage(),
        ),
        routes: [
          GoRoute(
            path: 'basic-data',
            name: 'basic-data',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const BasicDataPage(),
            ),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const SettingsPage(),
            ),
          ),
          GoRoute(
            path: 'schedule',
            name: 'schedule',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const SchedulePage(),
            ),
          ),
          GoRoute(
            path: 'about',
            name: 'about',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const AboutPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/appointment',
        name: 'appointment',
        pageBuilder: (context, state) => _noTransitionPage(
          state: state,
          child: const AppointmentsPage(),
        ),
        routes: [
          GoRoute(
            path: 'pre-consultation',
            name: 'pre-consultation',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const PreConsultationPage(),
            ),
          ),
          GoRoute(
            path: 'live-consultation',
            name: 'live-consultation',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const doctor_appointment.LiveConsultationPage(
                  consultationId: ''),
            ),
          ),
          GoRoute(
            path: 'live/:id',
            name: 'doctor-live-consultation',
            pageBuilder: (context, state) {
              final consultationId = state.pathParameters['id'] ?? '';
              return _noTransitionPage(
                state: state,
                child: doctor_appointment.LiveConsultationPage(
                    consultationId: consultationId),
              );
            },
          ),
          GoRoute(
            path: 'prescription-products',
            name: 'prescription-products',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const PrescriptionProductsPage(),
            ),
          ),
          GoRoute(
            path: 'prescription-details',
            name: 'prescription-details',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const PrescriptionDetailsPage(),
            ),
          ),
          GoRoute(
            path: 'finish',
            name: 'finish-appointment',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const FinishAppointmentPage(),
            ),
          ),
          GoRoute(
            path: 'details',
            name: 'appointment-details',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const AppointmentDetailsPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/financial',
        name: 'financial',
        pageBuilder: (context, state) => _noTransitionPage(
          state: state,
          child: const FinancialPage(),
        ),
        routes: [
          GoRoute(
            path: 'history',
            name: 'financial-history',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const FinancialHistoryPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) => _noTransitionPage(
          state: state,
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: '/catalog',
        name: 'catalog',
        pageBuilder: (context, state) => _noTransitionPage(
          state: state,
          child: const CatalogPage(),
        ),
        routes: [
          GoRoute(
            path: 'product-details',
            name: 'product-details',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const ProductDetailsPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/patient/account',
        name: 'patient-account',
        pageBuilder: (context, state) => _noTransitionPage(
          state: state,
          child: const PatientAccountPage(),
        ),
        routes: [
          GoRoute(
            path: 'basic-data',
            name: 'patient-basic-data',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const PatientBasicDataPage(),
            ),
          ),
          GoRoute(
            path: 'anvisa',
            name: 'patient-anvisa',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const PatientAnvisaPage(),
            ),
          ),
          GoRoute(
            path: 'settings',
            name: 'patient-settings',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const PatientSettingsPage(),
            ),
          ),
          GoRoute(
            path: 'about',
            name: 'patient-about',
            pageBuilder: (context, state) => _noTransitionPage(
              state: state,
              child: const PatientAboutPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/patient/orders',
        name: 'patient-orders',
        pageBuilder: (context, state) => _noTransitionPage(
          state: state,
          child: const OrdersHistoryPage(),
        ),
        routes: [
          // IMPORTANTE: 'new' deve vir ANTES de ':id' para evitar conflito de rotas
          GoRoute(
            path: 'new',
            name: 'patient-new-order',
            redirect: (context, state) {
              // Só redireciona se a URL for exatamente /patient/orders/new
              // Não redireciona se for uma sub-rota (step2, step3, etc.)
              if (state.uri.path == '/patient/orders/new') {
                return '/patient/orders/new/step1';
              }
              return null; // Não redireciona para sub-rotas
            },
            routes: [
              GoRoute(
                path: 'step1',
                name: 'patient-new-order-step1',
                pageBuilder: (context, state) => _noTransitionPage(
                  state: state,
                  child: const NewOrderStep1Page(),
                ),
              ),
              GoRoute(
                path: 'step2',
                name: 'patient-new-order-step2',
                pageBuilder: (context, state) {
                  final formData = state.extra as NewOrderFormData?;
                  return _noTransitionPage(
                    state: state,
                    child: NewOrderStep2Page(formData: formData),
                  );
                },
              ),
              GoRoute(
                path: 'step3',
                name: 'patient-new-order-step3',
                pageBuilder: (context, state) {
                  final formData = state.extra as NewOrderFormData?;
                  return _noTransitionPage(
                    state: state,
                    child: NewOrderStep3Page(formData: formData),
                  );
                },
              ),
              GoRoute(
                path: 'step4',
                name: 'patient-new-order-step4',
                pageBuilder: (context, state) {
                  final formData = state.extra as NewOrderFormData?;
                  return _noTransitionPage(
                    state: state,
                    child: NewOrderStep4Page(formData: formData),
                  );
                },
              ),
              GoRoute(
                path: 'step5',
                name: 'patient-new-order-step5',
                pageBuilder: (context, state) {
                  final formData = state.extra as NewOrderFormData?;
                  return _noTransitionPage(
                    state: state,
                    child: NewOrderStep5Page(formData: formData),
                  );
                },
              ),
              GoRoute(
                path: 'success',
                name: 'patient-order-payment-success',
                pageBuilder: (context, state) {
                  final data = state.extra as Map<String, dynamic>?;
                  final orderId = data?['orderId'] as String? ?? '';
                  final productName =
                      data?['productName'] as String? ?? 'Pedido';
                  final totalFormatted =
                      data?['totalFormatted'] as String? ?? 'R\$ 0,00';
                  final deliveryEstimate =
                      data?['deliveryEstimate'] as String? ?? 'A confirmar';
                  return _noTransitionPage(
                    state: state,
                    child: OrderPaymentSuccessPage(
                      orderId: orderId,
                      productName: productName,
                      totalFormatted: totalFormatted,
                      deliveryEstimate: deliveryEstimate,
                    ),
                  );
                },
              ),
            ],
          ),
          // ':id' deve ser a ÚLTIMA rota para não capturar 'new'
          GoRoute(
            path: ':id',
            name: 'patient-order-details',
            pageBuilder: (context, state) {
              final orderId = state.pathParameters['id'] ?? '';
              return _noTransitionPage(
                state: state,
                child: OrderDetailsPage(orderId: orderId),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/patient/consultations',
        name: 'patient-consultations',
        pageBuilder: (context, state) => _noTransitionPage(
          state: state,
          child: const ConsultationsPage(),
        ),
        routes: [
          // IMPORTANTE: 'new' deve vir ANTES de ':id' para evitar conflito de rotas
          GoRoute(
            path: 'new',
            name: 'patient-new-consultation',
            redirect: (context, state) {
              // Só redireciona se a URL for exatamente /patient/consultations/new
              // Não redireciona se for uma sub-rota (step2, step3, etc.)
              if (state.uri.path == '/patient/consultations/new') {
                return '/patient/consultations/new/step1';
              }
              return null; // Não redireciona para sub-rotas
            },
            routes: [
              GoRoute(
                path: 'step1',
                name: 'patient-new-consultation-step1',
                pageBuilder: (context, state) => _noTransitionPage(
                  state: state,
                  child: const NewConsultationStep1Page(),
                ),
              ),
              GoRoute(
                path: 'step2',
                name: 'patient-new-consultation-step2',
                pageBuilder: (context, state) {
                  final formData = state.extra as NewConsultationFormData?;
                  return _noTransitionPage(
                    state: state,
                    child: NewConsultationStep2Page(formData: formData),
                  );
                },
              ),
              GoRoute(
                path: 'step3',
                name: 'patient-new-consultation-step3',
                pageBuilder: (context, state) {
                  final formData = state.extra as NewConsultationFormData?;
                  return _noTransitionPage(
                    state: state,
                    child: NewConsultationStep3Page(formData: formData),
                  );
                },
              ),
              GoRoute(
                path: 'step4',
                name: 'patient-new-consultation-step4',
                pageBuilder: (context, state) {
                  final formData = state.extra as NewConsultationFormData?;
                  return _noTransitionPage(
                    state: state,
                    child: NewConsultationStep4Page(formData: formData),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'live/:id',
            name: 'patient-live-consultation',
            pageBuilder: (context, state) {
              final consultationId = state.pathParameters['id'] ?? '';
              return _noTransitionPage(
                state: state,
                child: LiveConsultationPage(consultationId: consultationId),
              );
            },
          ),
          GoRoute(
            path: 'finish/:id',
            name: 'patient-finish-consultation',
            pageBuilder: (context, state) {
              final consultationId = state.pathParameters['id'] ?? '';
              return _noTransitionPage(
                state: state,
                child: FinishConsultationPage(consultationId: consultationId),
              );
            },
          ),
          // ':id' deve ser a ÚLTIMA rota para não capturar 'new', 'live' ou 'finish'
          GoRoute(
            path: ':id',
            name: 'patient-consultation-details',
            pageBuilder: (context, state) {
              final consultationId = state.pathParameters['id'] ?? '';
              return _noTransitionPage(
                state: state,
                child: ConsultationDetailsPage(consultationId: consultationId),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/patient/prescriptions',
        name: 'patient-prescriptions',
        pageBuilder: (context, state) => _noTransitionPage(
          state: state,
          child: const PrescriptionsPage(),
        ),
      ),
      GoRoute(
        path: '/patient/home',
        name: 'patient-home',
        pageBuilder: (context, state) => _noTransitionPage(
          state: state,
          child: const PatientHomePage(),
        ),
      ),
      GoRoute(
        path: '/patient/catalog',
        name: 'patient-catalog',
        pageBuilder: (context, state) => _noTransitionPage(
          state: state,
          child: const patient_catalog.PatientCatalogPage(),
        ),
        routes: [
          GoRoute(
            path: 'product-details/:id',
            name: 'patient-product-details',
            pageBuilder: (context, state) {
              final productId = state.pathParameters['id'] ?? '';
              return _noTransitionPage(
                state: state,
                child: patient_product.PatientProductDetailsPage(
                    productId: productId),
              );
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
