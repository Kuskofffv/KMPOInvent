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
                'assets/images/20.jpg',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                '''\t\t\t\tВойдя в аккаунт, вы можете выбрать необходимую функцию в главном меню - вызов справки по приложению (справа сверху), кнопки «Начать инвентаризацию», «Календарь», «Сканировать QR-код», «Объекты», «Добавить объект», «Загрузка данных», «Архив инвентаризаций», «Список местоположений» и «Выход из аккаунта». .''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/new/22.jpg',
                scale: 2,
              ),
              const SizedBox(
                height: 40,
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
                height: 40,
              ),
              const Text(
                '''\t\t\t\tОбъектом в приложении служит любой предмет, у которого есть инвентарный номер. Для добавления объекта вам нужно нажать на кнопку "Добавить объект" и заполнить форму необходимыми данными для генерации QR-кода с возможностью последующего вывода на печать.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/23.jpg',
                scale: 2,
              ),


              const SizedBox(
                height: 40,
              ),
              const Text(
                '''\t\t\t\tДля пакетного добавления объектов был разработан модуль импортирования информации об имеющихся материальных ресурсах из файлов Excel (*.xlsx) с размером файла до 5000 строк. Для выгрузки берется информация из столбцов «Основное средство», «Инвентарный номер», «Балансовая стоимость», «Количество».''',
                textAlign: TextAlign.justify,
              ),

              const SizedBox(
                height: 40,
              ),
              const Text(
                '''\t\t\t\tДля импорта необходим файл с расширением xlsx, предварительно загруженный в память устройства. После нажатия на кнопку «Загрузка данных» из главного меню приложения выбирается материально-ответственное лицо, отвечающее за импортируемые объекты, выбирается необходимый файл по нажатию на кнопку «Выбор файла» и после парсинга файл  и появлении сообщения об успешном импорте, содержащиеся в файле объекты добавляются в БД.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/38.jpg',
                scale: 2,
              ),

              const SizedBox(
                height: 40,
              ),
              const Text(
                '''\t\t\t\tПосле успешного заполнения данных, либо импортирования данных из файла, из строки инвентарного номера, являющейся уникальной, генерируется QR-код (с указанным инвентарным номером снизу), который в дальнейшем можно сохранить, отправить на почту или распечатать на принтере. О каждом объекте также доступна информация посредством нажатия на карточку объекта.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/25.jpg',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),

              const SizedBox(
                height: 40,
              ),
              const Text(
                '''\t\t\t\tПосле массового импорта объектов также доступна возможность печати QR-кодов. Для этого необходимо в списке объектов нажать на иконку принтера, расположенную в правом верхнем углу. После этого необходимо выбрать все объекты, для которых нужно напечатать QR-код объекта, выбрать размер QR-кодов из трех вариантов: 2х3, 3х4 или 4х5. При выборе варианта 4х5, четыре QR-кода помещается по ширине листа, пять QR-кодов – по высоте листа. Формат листа установлен по умолчанию А4.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/42.jpg',
                scale: 2,
              ),


              const SizedBox(
                height: 40,
              ),
              const Text(
                '''\t\t\t\tПо нажатию на кнопку «напечатать» формируется файл с расширением pdf, который при необходимости можно «в один клик» отправить в любое установленное приложение, по электронной почте или же непосредственно на печать, при наличии приложения для печати с телефона.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/44.jpg',
                scale: 2,
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
                '''\t\t\t\tВ главном меню можно отсканировать QR-код объекта, после чего запускается встроенный сканер QR-кодов. В случае успешного считывания кода пользователь может выбрать операцию, которую хочет совершить над данными об объекте. После нажатия на кнопку «Посмотреть данные» пользователь получит данные объекта. Удалить данные объекта можно нажав на кнопку «удалить объект».''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/24.jpg',
                scale: 2,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/26.jpg',
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
                '''\t\t\t\tВыбрав в главном меню «Начать инвентаризацию», пользователь перейдёт на страницу с вводом имён сотрудников, которые будут участвовать в инвентаризации. После их ввода сотрудники должны приступить к сканированию и поиску объектов.''',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/28.jpg',
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
