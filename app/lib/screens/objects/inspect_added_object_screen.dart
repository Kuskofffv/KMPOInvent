import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:kmpo_invent/services/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InspectAddedObjectScreen extends StatefulWidget {
  final String qrData;
  final bool hasBackToMainButton;

  const InspectAddedObjectScreen(
      {required this.qrData, required this.hasBackToMainButton});

  @override
  State<InspectAddedObjectScreen> createState() =>
      _InspectAddedObjectScreenState();
}

class _InspectAddedObjectScreenState extends State<InspectAddedObjectScreen> {
  final qrKey = GlobalKey();
  QrCardSize _qrSize = QrCardSize.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR-Code',
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RepaintBoundary(
                  key: qrKey,
                  child: Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Text(
                          'KMPOInvent',
                          style: TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                        QrImageView(
                          //место где будет показан QR код
                          data: widget.qrData,
                          size: 300,
                        ),
                        Text(
                          widget.qrData,
                          style: const TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 21,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            listTileTheme: const ListTileThemeData(
                              horizontalTitleGap: 0,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                  child: Text(
                                "Размер: ",
                                style: TextStyle(fontSize: 16),
                              )),
                              ...QrCardSize.values.map((size) {
                                return Expanded(
                                  child: RadioListTile<QrCardSize>(
                                      contentPadding: EdgeInsets.zero,
                                      value: size,
                                      groupValue: _qrSize,
                                      title: Text(size.title),
                                      onChanged: (value) {
                                        setState(() {
                                          _qrSize = value!;
                                        });
                                      }),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await QrUtil.share([widget.qrData], _qrSize);
                      },
                      child: const Text(
                        "Сохранить QR-Code",
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (widget.hasBackToMainButton)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black54),
                        onPressed: () async {
                          SRRouter.popUntilTop(context);
                        },
                        child: const Text(
                          'Вернуться на главную',
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
