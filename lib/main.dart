import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:universe_template/app/app.dart';
import 'package:universe_template/observer.dart';
import 'package:universe_template/i18n/strings.g.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();

//* hive local database setup
  await Hive.initFlutter();
  Hive.registerAdapter(NoteDtoAdapter());
  Hive.registerAdapter(TodoDtoAdapter());
  await Hive.openBox(databaseBox);

  //* Update statusbar theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );


  //* inject dependencies
  //configureInjection(Environment.dev);

  await BlocOverrides.runZoned(
    () async => runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<HomeBloc>(
            create: (_) =>
                getIt<HomeBloc>()..add(const HomeEvent.getAllNotes()),
          ),
          BlocProvider<AddUpdateFormBloc>(
            create: (_) => getIt<AddUpdateFormBloc>(),
          ),
          BlocProvider<AddUpdateBloc>(
            create: (_) => getIt<AddUpdateBloc>(),
          ),
          BlocProvider<NoteActionBloc>(
            create: (_) => getIt<NoteActionBloc>(),
          ),
          BlocProvider<NoteDetailBloc>(
            create: (_) => getIt<NoteDetailBloc>(),
          ),
          BlocProvider<MultipleDeleteBloc>(
            create: (_) => getIt<MultipleDeleteBloc>(),
          ),
        ],
        child: const TranslationProvider(child: App(),),
      ),
    ),
    blocObserver: MyBlocObserver(),
  );
}
