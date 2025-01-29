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
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(20),
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
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                '''\t\t\t\tДля начала использования приложения, необходимо пройти регистрацию. Вам необходимо ввести своё ФИО, наименование отдела, электронную почту и пароль. После регистрации на почту приходит письмо со ссылкой для подтверждения регистрации. При переходе по ссылке всплывает сообщение о том, что введенный email подтвержден, после чего можно пользоваться приложением.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                "assets/images/20.png",
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tВойдя в аккаунт, вы можете выбрать необходимую функцию в главном меню - вызов справки по приложению (справа сверху), кнопки «Начать инвентаризацию», «Календарь», «Сканировать QR-код», «Объекты», «Добавить объект», «Загрузка данных», «Архив инвентаризаций», «Список местоположений» и «Выход из аккаунта».''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/22.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Добавление объектов в БД',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tОбъектом в приложении служит любой предмет, у которого есть инвентарный номер. Для добавления объекта вам нужно нажать на кнопку "Добавить объект" и заполнить форму необходимыми данными для генерации QR-кода с возможностью последующего вывода на печать.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/23.png',
                scale: 2,
              ),


              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tДля пакетного добавления объектов был разработан модуль импортирования информации об имеющихся материальных ресурсах из файлов Excel (*.xlsx) с размером файла до 5000 строк. Для выгрузки берется информация из столбцов «Основное средство», «Инвентарный номер», «Балансовая стоимость», «Количество». Пример содержимого файла, доступного для импорта, представлен на рисунке ниже''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/21.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tДля импорта необходим файл с расширением xlsx, предварительно загруженный в память устройства. После нажатия на кнопку «Загрузка данных» из главного меню приложения выбирается материально-ответственное лицо, отвечающее за импортируемые объекты, выбирается необходимый файл по нажатию на кнопку «Выбор файла» и после парсинга файл  и появлении сообщения об успешном импорте, содержащиеся в файле объекты добавляются в БД.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/24.png',
                scale: 2,
              ),

              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tПосле успешного заполнения данных, либо импортирования данных из файла, из строки инвентарного номера, являющейся уникальной, генерируется QR-код (с указанным инвентарным номером снизу), который в дальнейшем можно сохранить, отправить на почту или распечатать на принтере. О каждом объекте также доступна информация посредством нажатия на карточку объекта.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/25.png',
                scale: 2,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                '''\t\t\t\tПосле массового импорта объектов также доступна возможность печати QR-кодов. Для этого необходимо в списке объектов нажать на иконку принтера, расположенную в правом верхнем углу. После этого необходимо выбрать все объекты, для которых нужно напечатать QR-код объекта, выбрать размер QR-кодов из трех вариантов: 2х3, 3х4 или 4х5. При выборе варианта 4х5, четыре QR-кода помещается по ширине листа, пять QR-кодов – по высоте листа. Формат листа установлен по умолчанию А4.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/26.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tПо нажатию на кнопку «напечатать» формируется файл с расширением pdf, который при необходимости можно «в один клик» отправить в любое установленное приложение, по электронной почте или же непосредственно на печать, при наличии приложения для печати с телефона.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/27.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Сканирование QR-кода объектов',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tДля просмотра информации по любому объекту, находящемуся в базе, вы можете запустить встроенный сканер QR-кодов при нажатии на кнопку "Сканируйте QR-код" в главном меню. В случае успешного считывания кода вы сможете выбрать операцию, которую хотите совершить над данными об объекте. После нажатия на кнопку «Посмотреть данные» вы увидите данные объекта. Удалить данные объекта можно после нажатия на кнопку «Удалить объект».''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/29.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/30.png',
                scale: 2,
              ),

              const SizedBox(
                height: 30,
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
                height: 30,
              ),
              const Text(
                '''\t\t\t\tВыбрав в главном меню «Начать инвентаризацию», вы перейдёте на страницу с вводом имён сотрудников, которые будут участвовать в инвентаризации. После их ввода сотрудники должны приступить к сканированию и поиску объектов.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/31.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tВ начале инвентаризации все объекты по умолчанию считаются ненайденными, карточка объекта обозначена серым цветом. Если QR-код отсканирован, то объект считается найденным, и он подсвечивается зелёным. Если же объект был не отсканирован, цвет карточки становится красным. Для сканирования QR-кода, сотруднику необходимо нажать на красную кнопку снизу, после чего запустится сканер с камерой. После чего можно приступать к сканированию.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/32.png',
                scale: 2,
              ),

              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tДля того, чтобы завершить инвентаризацию, вам необходимо нажать на кнопку в правом верхнем углу. После этого на экране появится результат текущей инвентаризации. Сразу после его формирования, он также будет опубликован в архиве, где находятся все ранее пройденные инвентаризации.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/33.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Планирование инвентаризаций. Календарь инвентаризаций',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tС помощью встроенного модуля «Календарь инвентаризаций», вы можете спланировать проведение инвентаризации по заданному графику. В календаре отображаются проведенные ранее инвентаризации с привязкой по дате. Для добавления события необходимо нажать на знак «+» в правом нижнем углу экрана, выставить дату и время проведения инвентаризации, отметить членов комиссии из списка, а также материально-ответственное лицо.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/34.png',
                scale: 2,
              ),

              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tПо наступлению данного времени придет push-уведомление, сообщающее о необходимости проведения инвентаризации. При нажатии на push-уведомление из интерфейса системы Android, происходит переход в приложение «KMPOInvent».''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/36.png',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tДля выхода из аккаунта необходимо нажать на серую кнопку «Выйти из аккаунта», расположенную в главном меню.''',
                textAlign: TextAlign.justify,
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
