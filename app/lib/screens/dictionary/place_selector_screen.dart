import 'package:kmpo_invent/widget/loader_widget.dart';

import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class PlaceSelectorScreen extends StatefulWidget {
  const PlaceSelectorScreen({super.key});

  @override
  State<PlaceSelectorScreen> createState() => _PlaceSelectorScreenState();
}

class _PlaceSelectorScreenState extends State<PlaceSelectorScreen> {
  final _loaderController = LoaderController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Местоположения',
        ),
      ),
      body: LoaderWidget<List<ParseObject>>(
          controller: _loaderController,
          operation: () async {
            final query = QueryBuilder<ParseObject>(ParseObject('Places'))
              ..setLimit(1000);
            final response = await query.query();

            if (!response.success) {
              // ignore: only_throw_errors
              throw response.error!.message;
            }

            return List<ParseObject>.from(response.results ?? []);
          },
          builder: (context, snapshot) {
            if (snapshot.data.isEmpty) {
              return const Center(
                child: Text('Нет данных'),
              );
            }

            return ListView.builder(
              itemBuilder: (context, index) {
                final place = snapshot.data[index].get<String>("name") ?? "";

                return InkWell(
                  onTap: () {
                    SRRouter.pop(context, place);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      place,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
              itemCount: snapshot.data.length,
            );
          }),
    );
  }
}
