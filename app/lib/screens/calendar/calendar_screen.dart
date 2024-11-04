import 'package:core/core_dependencies.dart';
import 'package:core/util/exception/app_exception.dart';
import 'package:core/util/routing/router.dart';
import 'package:core/util/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:kmpo_invent/screens/archive/invent_info_screen.dart';
import 'package:kmpo_invent/screens/calendar/calendar_util.dart';
import 'package:kmpo_invent/screens/invent/select_objects_invent_screen.dart';
import 'package:kmpo_invent/utils/date.dart';
import 'package:kmpo_invent/utils/util.dart';
import 'package:kmpo_invent/widget/loader_widget.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../../utils/calendar/flutter_neat_and_clean_calendar.dart';
import '../invent/start_invent_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  final _controller = LoaderController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Календарь',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            locale: const Locale("ru", "RU"),
            initialDate: _selectedDate.isBefore(DateTime.now())
                ? DateTime.now()
                : _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime(2101),
          );

          if (pickedDate == null) {
            return;
          }

          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime == null) {
            return;
          }

          await SRRouter.push(context, InventStartScreen(
            customCallback: (comission, mols) async {
              final events = await CalendarUtil.storage.read() ?? [];
              final eventDate = DateTime(pickedDate.year, pickedDate.month,
                  pickedDate.day, pickedTime.hour, pickedTime.minute);
              events.add(
                DynamicModel()
                  ..set(
                    "id",
                    AppUtil.randomInt(),
                  )
                  ..set(
                    "date",
                    DateFormatUtil.strFromDate(eventDate),
                  )
                  ..set("comission", comission)
                  ..set("mols", mols),
              );
              await CalendarUtil.storage.write(events);
              await CalendarUtil.scheduleAll();
            },
          ));
        },
        backgroundColor: ThemeUtil.accent,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: LoaderWidget(
          controller: _controller,
          operation: () async {
            final query = QueryBuilder<ParseObject>(ParseObject('Invents'))
              ..setLimit(1000)
              ..orderByDescending("createdAt");
            final response = await query.query();

            if (!response.success) {
              throw AppException(response.error!.message);
            }
            return List<ParseObject>.from(response.results ?? []);
          },
          builder: (context, archive) {
            return StorageBuilder(
              storage: CalendarUtil.storage,
              builder: (context, snapshot) {
                if (snapshot.hasBeenRead == false) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final events = snapshot.data ?? [];
                final eventsList = events.map((e) {
                  final date =
                      DateFormatUtil.dateFromStr(e.stringOpt("date") ?? "") ??
                          DateTime.now();

                  return NeatCleanCalendarEvent(
                      "Комиссия: ${e.stringListOpt("comission")?.join(", ")}\n"
                      "МОЛ: ${e.stringListOpt("mols")?.join(", ")}",
                      startTime: date,
                      endTime: date,
                      metadata: {
                        "data": e.clone()..set("type", EventType.calendar)
                      });
                }).toList();

                // ignore: cascade_invocations
                eventsList.addAll(archive.data.map((d) {
                  final date = d.createdAt?.toLocal() ?? DateTime.now();
                  return NeatCleanCalendarEvent(
                      "Комиссия: ${d.get<String>("names") ?? ""}\n"
                      "МОЛ: ${d.get<String>("user_name") ?? ""}",
                      startTime: date,
                      endTime: date,
                      metadata: {
                        "data": DynamicModel.fromJson(d.toJson())
                          ..set("type", EventType.archive)
                          ..set("success", (d.get<Map>("list") ?? {}).isEmpty),
                        "parseObject": d
                      });
                }));

                return SafeArea(
                  child: Calendar(
                    onDateSelected: (date) => setState(() {
                      _selectedDate = date;
                    }),
                    eventCellBuilder: (context, event, start, end) {
                      final data = event.metadata!["data"] as DynamicModel;
                      final Color color;
                      if (data.stringOpt("type") == EventType.archive) {
                        color = data.boolOpt("success") != true
                            ? ThemeUtil.red
                            : ThemeUtil.green;
                      } else {
                        color = ThemeUtil.black80;
                      }

                      return _buildItem(context, data, event, color, start);
                    },
                    startOnMonday: true,
                    weekDays: const ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'],
                    eventsList: eventsList,
                    isExpandable: true,
                    eventDoneColor: ThemeUtil.green,
                    selectedColor: ThemeUtil.accent,
                    selectedTodayColor: ThemeUtil.accent,
                    todayColor: ThemeUtil.accent,
                    hideTodayIcon: true,
                    topRowIconColor: ThemeUtil.accent,
                    eventColor: ThemeUtil.accent,
                    locale: "ru_RU",
                    isExpanded: true,
                    expandableDateFormat: 'EEEE, dd MMMM yyyy',
                    titleDateFormat: 'LLLL yyyy',
                    datePickerType: DatePickerType.hidden,
                    showEventListViewIcon: false,
                    dayOfWeekStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 11),
                  ),
                );
              },
            );
          }),
    );
  }

  GestureDetector _buildItem(BuildContext context, DynamicModel data,
      NeatCleanCalendarEvent event, Color color, String start) {
    return GestureDetector(
      onTap: () async {
        if (data.stringOpt("type") == EventType.archive) {
          final parseObject = event.metadata!["parseObject"] as ParseObject;
          final id = parseObject.objectId ?? "";
          await SRRouter.push(
              context,
              InventInfoScreen(
                id: id,
                names: parseObject.get<String>("names"),
                listObj: parseObject.get("list"),
                timeEnd: DateFormatUtil.strFromDate(
                    parseObject.createdAt?.toLocal()),
                parseObject: parseObject,
              ));
        } else if (data.stringOpt("type") == EventType.calendar) {
          if (event.startTime.isBefore(DateTime.now())) {
            await SRRouter.push(
                context,
                SelectObjectsInventScreen(
                  names: data.stringListOpt('comission') ?? [],
                  mols: data.stringListOpt('mols') ?? [],
                  calendarEventId: data.intOpt('id'),
                ));
            await _controller.loadData();
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 5, 12),
        child: Row(
          children: [
            const SizedBox(
              width: 8,
            ),
            Container(
              width: 3,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
                child: Text(
              event.summary,
              style: const TextStyle(fontSize: 16),
            )),
            Text(
              start,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(
              width: 8,
            ),
            if (data.stringOpt("type") == EventType.calendar)
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: ThemeUtil.black80,
                ),
                onPressed: () async {
                  AppUtil.areYouSure(
                    context,
                    title: "Удаление события",
                    message: "Вы уверены, что хотите удалить событие?",
                    button: "Удалить",
                    onPerform: () async {
                      final events = await CalendarUtil.storage.read() ?? [];
                      // ignore: cascade_invocations
                      events.removeWhere(
                          (e) => e.intOpt("id") == data.intOpt("id"));
                      await CalendarUtil.storage.write(events);
                      await CalendarUtil.scheduleAll();
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

abstract class EventType {
  static const String archive = "archive";
  static const String calendar = "calendar";
}
