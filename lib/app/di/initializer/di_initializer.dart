import 'package:easy_flutter/easy_flutter.dart';
import 'package:easy_flutter_boilerplate/app/di/initializer/core_initializer.dart';
import 'package:easy_flutter_boilerplate/app/di/initializer/data_source_initializer.dart';
import 'package:easy_flutter_boilerplate/app/di/initializer/network_initializer.dart';
import 'package:easy_flutter_boilerplate/app/di/initializer/repository_initializer.dart';
import 'package:easy_flutter_boilerplate/app/di/initializer/use_case_initializer.dart';

class DiInitializer implements Initializer {
  @override
  Future<void> init() async {
    await CoreInitializer().init();
    await NetworkInitializer().init();
    await DataSourceInitializer().init();
    await RepositoryInitializer().init();
    await UseCaseInitializer().init();
  }
}
