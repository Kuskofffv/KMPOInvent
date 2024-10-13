import 'package:core/util/exception/app_exception.dart';
import 'package:kmpo_invent/screens/archive/invent_info_screen.dart';
import 'package:kmpo_invent/utils/date.dart';
import 'package:kmpo_invent/widget/loader_widget.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class InventListScreen extends StatefulWidget {
  const InventListScreen({Key? key}) : super(key: key);

  @override
  _InventListStatePage createState() => _InventListStatePage();
}

class _InventListStatePage extends State<InventListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Архив',
        ),
      ),
      body: LoaderWidget(operation: () async {
        final query = QueryBuilder<ParseObject>(ParseObject('Invents'))
          ..setLimit(1000)
          ..orderByDescending("createdAt");
        final response = await query.query();

        if (!response.success) {
          throw AppException(response.error!.message);
        }

        return List<ParseObject>.from(response.results ?? []);
      }, builder: (context, snapshot) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          itemBuilder: (context, index) {
            final data = snapshot.data[index];
            final list = data.get<Map>("list") ?? {};
            return Card(
              color: list.isNotEmpty ? Colors.red : Colors.green,
              child: ListTile(
                leading: const Icon(
                  Icons.inventory,
                  color: Colors.white,
                ),
                trailing: const Icon(
                  Icons.turn_right,
                  color: Colors.white,
                ),
                title: Text(
                  '${DateFormatUtil.strFromDate(DateFormatUtil.dateFromStr(data.get<String>("start_date")), formatter: "dd.MM.yyyy HH:mm")} - ${DateFormatUtil.strFromDate(data.createdAt?.toLocal(), formatter: "dd.MM.yyyy HH:mm")}',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${data['names']}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                onTap: () {
                  final id = data.objectId ?? "";
                  SRRouter.push(
                      context,
                      InventInfoScreen(
                        id: id,
                        names: data.get<String>("names"),
                        listObj: data.get("list"),
                        timeEnd: DateFormatUtil.strFromDate(
                            data.createdAt?.toLocal()),
                        parseObject: data,
                      ));
                },
              ),
            );
          },
          itemCount: snapshot.data.length,
        );
      }),
    );
  }
}
