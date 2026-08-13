# Another Home

This project has been reorganized around clean architecture principles.

## Architecture

- Domain layer: entities, repositories, and use cases define business rules.
- Data layer: repository implementations isolate data access and framework concerns.
- Presentation layer: pages and widgets depend on use cases rather than concrete implementations.
- Dependency rule: inner layers are independent of UI, framework, and database choices.

## Project structure

- lib/features/auth: authentication flow
- lib/features/dashboard: dashboard and module pages
- lib/core/di: dependency injection container
