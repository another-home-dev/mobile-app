import 'package:another_home/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:another_home/features/auth/domain/repositories/auth_repository.dart';
import 'package:another_home/features/auth/domain/usecases/login_usecase.dart';
import 'package:another_home/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:another_home/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:another_home/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:another_home/core/network/api_client.dart';
import 'package:another_home/core/network/services/auth_api_service.dart';
import 'package:another_home/core/network/services/accommodation_api_service.dart';
import 'package:another_home/core/network/services/operations_api_service.dart';
import 'package:another_home/core/network/services/finance_api_service.dart';
import 'package:another_home/core/network/services/notifications_api_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator _instance = ServiceLocator._();

  factory ServiceLocator() => _instance;

  static ServiceLocator get instance => _instance;

  // Base API Client
  late final ApiClient apiClient = ApiClient();

  // API Services corresponding to Backend Microservices
  late final AuthApiService authApiService = AuthApiService(apiClient);
  late final AccommodationApiService accommodationApiService = AccommodationApiService(apiClient);
  late final OperationsApiService operationsApiService = OperationsApiService(apiClient);
  late final FinanceApiService financeApiService = FinanceApiService(apiClient);
  late final NotificationsApiService notificationsApiService = NotificationsApiService(apiClient);

  late final AuthRepository authRepository = AuthRepositoryImpl();
  late final LoginUseCase loginUseCase = LoginUseCase(authRepository);

  late final DashboardRepository dashboardRepository = DashboardRepositoryImpl();
  late final GetDashboardSummaryUseCase dashboardSummaryUseCase =
      GetDashboardSummaryUseCase(dashboardRepository);
}
