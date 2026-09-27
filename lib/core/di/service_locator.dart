import 'package:another_home/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:another_home/features/auth/domain/repositories/auth_repository.dart';
import 'package:another_home/features/auth/domain/usecases/login_usecase.dart';
import 'package:another_home/features/auth/domain/usecases/logout_usecase.dart';
import 'package:another_home/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:another_home/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:another_home/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:another_home/core/network/api_client.dart';
import 'package:another_home/core/network/services/auth_api_service.dart';
import 'package:another_home/core/network/services/accommodation_api_service.dart';
import 'package:another_home/core/network/services/operations_api_service.dart';
import 'package:another_home/core/network/services/finance_api_service.dart';
import 'package:another_home/core/network/services/notifications_api_service.dart';
import 'package:another_home/features/operations/data/repositories/operations_repository_impl.dart';
import 'package:another_home/features/operations/domain/repositories/operations_repository.dart';
import 'package:another_home/features/operations/domain/usecases/get_incidents_usecase.dart';
import 'package:another_home/features/operations/domain/usecases/report_incident_usecase.dart';
import 'package:another_home/features/operations/domain/usecases/get_visitors_usecase.dart';
import 'package:another_home/features/operations/domain/usecases/request_visitor_usecase.dart';
import 'package:another_home/features/operations/domain/usecases/get_notices_usecase.dart';
import 'package:another_home/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:another_home/features/finance/domain/repositories/finance_repository.dart';
import 'package:another_home/features/finance/domain/usecases/get_invoices_usecase.dart';
import 'package:another_home/features/finance/domain/usecases/submit_payment_usecase.dart';
import 'package:another_home/features/accommodation/data/repositories/accommodation_repository_impl.dart';
import 'package:another_home/features/accommodation/domain/repositories/accommodation_repository.dart';
import 'package:another_home/features/accommodation/domain/usecases/get_current_student_usecase.dart';
import 'package:another_home/features/accommodation/domain/usecases/update_student_profile_usecase.dart';
import 'package:another_home/features/accommodation/domain/usecases/get_my_room_usecase.dart';
import 'package:another_home/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:another_home/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:another_home/features/notifications/domain/usecases/get_alerts_usecase.dart';
import 'package:another_home/features/notifications/domain/usecases/mark_alert_as_read_usecase.dart';
import 'package:another_home/core/services/secure_storage_service.dart';
import 'package:another_home/core/services/push_notification_service.dart';


class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator _instance = ServiceLocator._();

  factory ServiceLocator() => _instance;

  static ServiceLocator get instance => _instance;

  // Base API Client
  late final ApiClient apiClient = ApiClient(secureStorage: secureStorageService);

  // Secure Storage
  late final SecureStorageService secureStorageService = SecureStorageService();

  // API Services corresponding to Backend Microservices
  late final AuthApiService authApiService = AuthApiService(apiClient, secureStorageService);
  late final AccommodationApiService accommodationApiService = AccommodationApiService(apiClient);
  late final OperationsApiService operationsApiService = OperationsApiService(apiClient, secureStorageService);
  late final FinanceApiService financeApiService = FinanceApiService(apiClient);
  late final NotificationsApiService notificationsApiService = NotificationsApiService(apiClient);
  late final PushNotificationService pushNotificationService = PushNotificationService(notificationsApiService);

  late final AuthRepository authRepository = AuthRepositoryImpl(authApiService, accommodationApiService, secureStorageService);
  late final LoginUseCase loginUseCase = LoginUseCase(authRepository);
  late final LogoutUseCase logoutUseCase = LogoutUseCase(authRepository);

  late final DashboardRepository dashboardRepository = DashboardRepositoryImpl(financeApiService, operationsApiService, secureStorageService);
  late final GetDashboardSummaryUseCase dashboardSummaryUseCase =
      GetDashboardSummaryUseCase(dashboardRepository);

  // Operations
  late final OperationsRepository operationsRepository = OperationsRepositoryImpl(operationsApiService);
  late final GetIncidentsUseCase getIncidentsUseCase = GetIncidentsUseCase(operationsRepository);
  late final ReportIncidentUseCase reportIncidentUseCase = ReportIncidentUseCase(operationsRepository);
  late final GetVisitorsUseCase getVisitorsUseCase = GetVisitorsUseCase(operationsRepository);
  late final RequestVisitorUseCase requestVisitorUseCase = RequestVisitorUseCase(operationsRepository);
  late final GetNoticesUseCase getNoticesUseCase = GetNoticesUseCase(operationsRepository);

  // Finance
  late final FinanceRepository financeRepository = FinanceRepositoryImpl(financeApiService, secureStorageService);
  late final GetInvoicesUseCase getInvoicesUseCase = GetInvoicesUseCase(financeRepository);
  late final SubmitPaymentUseCase submitPaymentUseCase = SubmitPaymentUseCase(financeRepository);

  // Accommodation
  late final AccommodationRepository accommodationRepository =
      AccommodationRepositoryImpl(accommodationApiService, secureStorageService);
  late final GetCurrentStudentUseCase getCurrentStudentUseCase = GetCurrentStudentUseCase(accommodationRepository);
  late final UpdateStudentProfileUseCase updateStudentProfileUseCase =
      UpdateStudentProfileUseCase(accommodationRepository);
  late final GetMyRoomUseCase getMyRoomUseCase = GetMyRoomUseCase(accommodationRepository);

  // Notifications (in-app alerts)
  late final NotificationsRepository notificationsRepository =
      NotificationsRepositoryImpl(notificationsApiService, secureStorageService);
  late final GetAlertsUseCase getAlertsUseCase = GetAlertsUseCase(notificationsRepository);
  late final MarkAlertAsReadUseCase markAlertAsReadUseCase = MarkAlertAsReadUseCase(notificationsRepository);
}
