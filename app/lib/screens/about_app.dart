import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Справка',
          style: TextStyle(
              fontFamily: 'Oswald', fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Начало работы в приложении',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                '''\t\t\t\tДля начала использования приложения, необходимо пройти регистрацию. Завести аккаунт можно без подтверждения почты, введя названия организации, адрес почты и пароль.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/1.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tПосле входа в аккаунт, перед вами появиться меню со следующими функциями: сканирование qr-code, добавление объекта, инвенторизация и архив проведённых инвенторизаций.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/2.png',
                scale: 2,
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                'Добавление объектов',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                '''\t\t\t\tОбъектом в приложении служит любой предмет, у которого есть инвентарный номер. Для добавления объекта вам нужно заполнить форму данными: инвентарный номер, название объекта, имя сотрудника(который добавляет данные), статус объекта(текующее его состояние), местонахождение объекта.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/3.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tQR-Code генерируется из инвентарного номера и сразу после добавления документа вы можете его сохранить.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/4.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tСнизу от QR-Code'a, находиться инвентарный номер, который поможет определить объект при инвенторизации.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                'Сканирование QR-Code',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                '''\t\t\t\tНажав на кнопку "Сканировать QR-Code", у вас откроется сканер. Если объект был ранее вами добавлен, на экране появиться меню, где можно выбрать 3 функции над данными: посмотреть, редактировать и удалить.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/5.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/6.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/7.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/8.png',
                scale: 2,
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                'Начать инвентаризацию',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                '''\t\t\t\tПеред тем как начать инвенторизацию, нужно написать имена тех кто будет проводить инвентаризацию.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/9.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tДля того чтобы успешно закончить инвенторизацию нужно отсканировать все объекты и нажать на кнопку в правом верхнем углу. Сканер включается после нажатия на карточку объекта. В случае если вы отсканировали qr не принадлежащий объекту, его карточка засветиться красным цветом. Если qr верный, цвет карточки будет зелёным.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/10.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tПосле того как инвенторизация будет пройдена, вы увидете страница с результатом.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/11.png',
                scale: 2,
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                'Архив',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                '''\t\t\t\tВ архиве будут карточки с пройденными инвенторизациями. Нажав на любую их них, вы можете увидеть результат их прохождения.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/12.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/13.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
