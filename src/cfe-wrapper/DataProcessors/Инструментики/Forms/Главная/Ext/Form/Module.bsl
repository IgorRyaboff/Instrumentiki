﻿
// --------------------------------------------------------------------------------
// Copyright (c) 2024-2025 Igor Ryabov (https://github.com/IgorRyaboff/Instrumentiki)
// License: https://github.com/IgorRyaboff/Instrumentiki/blob/main/LICENSE
// --------------------------------------------------------------------------------

#Область ОписаниеПеременных
//
#КонецОбласти

#Область ПрограммныйИнтерфейс

#Область БСП

&НаКлиенте
Процедура ВыполнитьКоманду(ИдентификаторКоманды, ОбъектыНазначенияМассив) Экспорт
	Если ИдентификаторКоманды = "ОткрытьОбъектВРедактореОбъектов" Тогда
		Если ОбъектыНазначенияМассив.Количество() > 1 Тогда
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = НСтр("ru='Вызов данной команды допустим только при выборе одного объекта'");
			Сообщение.Сообщить();
			Возврат;
		КонецЕсли;
		
		ПараметрыФормы = Новый Структура("Ссылка", ОбъектыНазначенияМассив[0]);
		ОткрытьФормуИнструмента("РедакторОбъектов", ПараметрыФормы, Истина);
	ИначеЕсли ИдентификаторКоманды = "СравнитьОбъекты" Тогда
		Если ОбъектыНазначенияМассив.Количество() <> 2 Тогда
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = НСтр("ru='Для сравнения реквизитов необходимо выделить два объекта в списке'");
			Сообщение.Сообщить();
			Возврат;
		КонецЕсли;
		
		ПараметрыФормы = Новый Структура("Ссылки", ОбъектыНазначенияМассив);
		ОткрытьФормуИнструмента("СравнениеРеквизитовОбъектов", ПараметрыФормы, Истина);
	Иначе
		ВызватьИсключение "Недопустимое имя команды";
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если ЗначениеЗаполнено(Объект.Версия) Тогда
		Заголовок = "Инструментики v" + Объект.Версия;
	КонецЕсли;
	
	Элементы.НадписьБезопасныйРежим.Видимость = Объект.БезопасныйРежим;
	Элементы.ФормаПереключитьЭкспериментальныеФункции.Пометка = Объект.ЭкспериментальныеФункции;
	Элементы.НадписьЗащитаОтОпасныхДействий.Видимость = Объект.ВключенаЗащитаОтОпасныхДействий;
	
	СИ = Новый СистемнаяИнформация;
	НаСервереWindows = СтрНачинаетсяС(Строка(СИ.ТипПлатформы), "Windows");
	
	ЗаполнитьСписокИнструментов();
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Для Каждого КорневаяСтрока Из СписокИнструментов.ПолучитьЭлементы() Цикл
		Элементы.СписокИнструментов.Развернуть(КорневаяСтрока.ПолучитьИдентификатор());
	КонецЦикла;
	
	СИ = Новый СистемнаяИнформация;
	НаКлиентеWindows = СтрНачинаетсяС(Строка(СИ.ТипПлатформы), "Windows");
	
	ПроверитьОбновленияАсинх();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура НадписьЗащитаОтОпасныхДействийОбработкаНавигационнойСсылки(Элемент,
	НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	
	Если Объект.БезопасныйРежим Тогда
		ПоказатьПредупреждение(, НСтр("ru='Данное действие недоступно при работе в безопасном режиме'"));
		Возврат;
	КонецЕсли;
	
	ОтключитьЗащитуОтОпасныхДействийАсинх();

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыСписокИнструментов

&НаКлиенте
Процедура СписокИнструментовВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	ТД = Элементы.СписокИнструментов.ТекущиеДанные;
	Если ТД = Неопределено Тогда
		Возврат;
	КонецЕсли;
	Если ПустаяСтрока(ТД.ИмяФормы) Тогда
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка = Ложь;
	ОткрытьФормуИнструмента(ТД.ИмяФормы);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОткрытьКаналTelegram(Команда)
	ПараметрыФормы = Новый Структура("Ссылка", "https://t.me/instrumentiki1C");
	ОткрытьФорму(Объект.ИмяМетаданныхОбработки + ".Форма.Общая_ВнешняяСсылка", ПараметрыФормы);
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьИнфостарт(Команда)
	ПараметрыФормы = Новый Структура("Ссылка", "https://infostart.ru/1c/tools/1946049");
	ОткрытьФорму(Объект.ИмяМетаданныхОбработки + ".Форма.Общая_ВнешняяСсылка", ПараметрыФормы);
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьGitHub(Команда)
	ПараметрыФормы = Новый Структура("Ссылка", "https://github.com/IgorRyaboff/Instrumentiki");
	ОткрытьФорму(Объект.ИмяМетаданныхОбработки + ".Форма.Общая_ВнешняяСсылка", ПараметрыФормы);
КонецПроцедуры

&НаКлиенте
Асинх Процедура ПоказатьИнформациюДляТехподдержки(Команда)
	ИнформацияОтСервера = ИнформацияДляТехподдержкиНаСервере();
	
	Результат = Новый Массив;
	
	Версия = ?(ЗначениеЗаполнено(Объект.Версия), Объект.Версия, НСтр("ru='<не заполнена>'"));
	Результат.Добавить("Версия Инструментиков: " + Версия);
	
	Результат.Добавить("Инструментики в безопасном режиме: " + Строка(Объект.БезопасныйРежим));
	Результат.Добавить("");
	
	СистИнфо = Новый СистемнаяИнформация;
	Результат.Добавить("Версия платформы: " + СистИнфо.ВерсияПриложения);
	Результат.Добавить("Тип платформы: " + СистИнфо.ТипПлатформы);
	
	#Если ТолстыйКлиентУправляемоеПриложение Тогда
		Результат.Добавить("Тип клиента: Толстый клиент");
	#ИначеЕсли ТонкийКлиент Тогда
		Результат.Добавить("Тип клиента: Тонкий клиент");
	#ИначеЕсли ВебКлиент Тогда
		Результат.Добавить("Тип клиента: Веб-клиент");
	#Иначе
		Результат.Добавить("Тип клиента: НЛО");
	#КонецЕсли
	Результат.Добавить("Текущий вариант интерфейса: " + Строка(ТекущийВариантИнтерфейсаКлиентскогоПриложения()));
	Результат.Добавить("");
		
	#Если ВебКлиент Тогда
		Результат.Добавить("Браузер: " + СистИнфо.ИнформацияПрограммыПросмотра);
	#Иначе
		Результат.Добавить("ОС клиента: " + СистИнфо.ВерсияОС);
		Результат.Добавить("Процессор клиента: " + СистИнфо.Процессор);
		Результат.Добавить("ОЗУ клиента (Мб): " + СистИнфо.ОперативнаяПамять);
	#КонецЕсли
	Результат.Добавить("");
	
	Результат.Добавить("ОС сервера: " + ИнформацияОтСервера.ОС);
	Результат.Добавить("Процессор сервера: " + ИнформацияОтСервера.Процессор);
	Результат.Добавить("ОЗУ сервера (Мб): " + ИнформацияОтСервера.ОперативнаяПамять);
	Результат.Добавить("");
	
	Результат.Добавить("Конфигурация: " + ИнформацияОтСервера.Конфигурация + " " + ИнформацияОтСервера.ВерсияКонфигурации);
	Результат.Добавить("Режим совместимости основной конфигурации: " + ИнформацияОтСервера.РежимСовместимости);
	Результат.Добавить("Режим совместимости интерфейса основной конфигурации: "
		+ ИнформацияОтСервера.РежимСовместимостиИнтерфейса);
	//
	Результат.Добавить("Режим работы ИБ: " + ИнформацияОтСервера.РежимРаботыИБ);
	
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.УстановитьТекст(СтрСоединить(Результат, Символы.ПС));
	ТекстовыйДокумент.ИспользуемоеИмяФайла = "Информация для техподдержки";
	ТекстовыйДокумент.Показать("Информация для техподдержки");
КонецПроцедуры

&НаКлиенте
Асинх Процедура ПроверитьНаличиеОбновлений(Команда)
	Если Не ЗначениеЗаполнено(Объект.Версия) Тогда
		ВызватьИсключение НСтр("ru='Не заполнена версия обработки'");
	КонецЕсли;
	
	Если Объект.БезопасныйРежим Тогда
		// BSLLS:LineLength-off (неделимый текст для вывода пользователю)
		ПоказатьПредупреждение(, "Данная функция недоступна в безопасном режиме
			|Для скачивания новой версии запустите Инструментики в небезопасном режиме или перейдите на страницу Инфостарта или канал Telegram",,
			"Ой, у вас безопасный режим");
		// BSLLS:LineLength-on
		Возврат;
	КонецЕсли;
	
	ОткрытьФорму(Объект.ИмяМетаданныхОбработки + ".Форма.Главная_Обновление",
		Новый Структура("ТекущаяВерсия", Объект.Версия));
	//
КонецПроцедуры

&НаКлиенте
Асинх Процедура УказатьПутьККрасивомуРедакторуКода(Команда)
	Кнопки = Новый СписокЗначений;
	Кнопки.Добавить("Макет", "Из встроенного в обработку макета");
	Кнопки.Добавить("Путь", "Указать свой путь к внешнему расположению");
	Кнопки.Добавить(Неопределено, "Отмена");
	Ответ = Ждать ВопросАсинх("Откуда брать редактор?", Кнопки,, "Макет");
	Если Ответ = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Ответ = "Макет" Тогда
		ЗаписатьПутьККрасивомуРедакторуКода(Неопределено);
	ИначеЕсли Ответ = "Путь" Тогда
		Путь = Ждать ВвестиСтрокуАсинх("", "Укажите путь");
		Если Путь = Неопределено Тогда
			Возврат;
		КонецЕсли;
		
		ЗаписатьПутьККрасивомуРедакторуКода(СокрЛП(Путь));
	Иначе
		Возврат;
	КонецЕсли;
	ПоказатьПредупреждение(, "Путь записан");
КонецПроцедуры

&НаКлиенте
Процедура СкрытьВерсиюИзЗаголовкаФормы(Команда)
	Заголовок = "Инструментики";
КонецПроцедуры

&НаКлиенте
Процедура ПереключитьЭкспериментальныеФункции(Команда)
	ЗаписатьНастройкуЭкспериментальныеФункции(Не Объект.ЭкспериментальныеФункции);
	
	Объект.ЭкспериментальныеФункции = Не Объект.ЭкспериментальныеФункции;
	Элементы.ФормаПереключитьЭкспериментальныеФункции.Пометка = Объект.ЭкспериментальныеФункции;
	
	ПоказатьПредупреждение(, НСтр("ru='Для вступления изменений в силу необходимо перезапустить обработку'"));
КонецПроцедуры

&НаКлиенте
Асинх Процедура ОчиститьВсеНастройкиИнструментиков(Команда)
	Ответ = Ждать ВопросАсинх(НСтр("ru = 'Будут очищены настройки всех инструментов Инструментиков.
    	|Продолжить?'"), РежимДиалогаВопрос.ДаНет);
	Если Ответ = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	ОчиститьВсеНастройкиИнструментиковНаСервере();
	Ждать ПредупреждениеАсинх(НСтр("ru='Все настройки Инструментиков очищены. Перезапустите обработку'"));
	Закрыть();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Сравнивает две версии
//
// Параметры
//  ВерсияСлева - Строка -
//  ВерсияСправа - Строка -
//
// Возвращаемое значение:
//  Число - "0", если версии совпадают; "1", если ВерсияСлева > ВерсияСправа; "-1", если ВерсияСлева < ВерсияСправа
&НаКлиентеНаСервереБезКонтекста
Функция СравнитьВерсии(ВерсияСлева, ВерсияСправа)
	ЧастиСлева = СтрРазделить(ВерсияСлева, ".");
	ЧастиСправа = СтрРазделить(ВерсияСправа, ".");
	
	КоличествоЧастей = 0;
	Если ЧастиСлева.Количество() > ЧастиСправа.Количество() Тогда
		КоличествоЧастей = ЧастиСлева.Количество();
	Иначе
		КоличествоЧастей = ЧастиСправа.Количество();
	КонецЕсли;
	
	Пока ЧастиСлева.Количество() < КоличествоЧастей Цикл
		ЧастиСлева.Добавить("0");
	КонецЦикла;
	Пока ЧастиСправа.Количество() < КоличествоЧастей Цикл
		ЧастиСправа.Добавить("0");
	КонецЦикла;
	
	Для Сч = 0 По КоличествоЧастей - 1 Цикл
		Слева = Число(ЧастиСлева[Сч]);
		Справа = Число(ЧастиСправа[Сч]);
		
		Если Слева > Справа Тогда
			Возврат -1;
		ИначеЕсли Слева < Справа Тогда
			Возврат 1;
		Иначе
			Продолжить;
		КонецЕсли;
	КонецЦикла;
	
	Возврат 0;
КонецФункции

// Заполнение списка инструментов
//
&НаСервере
Процедура ЗаполнитьСписокИнструментов()
	Группы = СписокИнструментов.ПолучитьЭлементы();
	Группы.Очистить();
	
	Группа = Группы.Добавить();
	Группа.Наименование = "Разработка";
	Группа.ЭтоГруппа = Истина;
	СтрокиГруппы = Группа.ПолучитьЭлементы();
	
	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Консоль HTTP-запросов";
	Инструмент.ИмяФормы = "КонсольHTTP";
	
	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Консоль WebSocket";
	Инструмент.ИмяФормы = "КонсольWebSocket";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Консоль запросов";
	Инструмент.ИмяФормы = "КонсольЗапросов";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Консоль кода";
	Инструмент.ИмяФормы = "КонсольКода";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Консоль СКД";
	Инструмент.ИмяФормы = "КонсольСКД";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Отладка регулярных выражений";
	Инструмент.ИмяФормы = "ОтладкаРегулярныхВыражений";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Проверка компиляции модулей менеджеров";
	Инструмент.ИмяФормы = "ПроверкаКомпиляцииМодулейМенеджеров";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Сравнение производительности кода";
	Инструмент.ИмяФормы = "СравнениеПроизводительностиКода";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Структура хранения базы данных";
	Инструмент.ИмяФормы = "СтруктураХраненияБД";
	
	Группа = Группы.Добавить();
	Группа.Наименование = "Редакторы";
	Группа.ЭтоГруппа = Истина;
	СтрокиГруппы = Группа.ПолучитьЭлементы();

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Редактор констант";
	Инструмент.ИмяФормы = "РедакторКонстант";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Редактор объектов";
	Инструмент.ИмяФормы = "РедакторОбъектов";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Редактор параметров сеанса";
	Инструмент.ИмяФормы = "РедакторПараметровСеанса";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Редактор регистров сведений";
	Инструмент.ИмяФормы = "РедакторРегистровСведений";
	
	Группа = Группы.Добавить();
	Группа.Наименование = "Администрирование";
	Группа.ЭтоГруппа = Истина;
	СтрокиГруппы = Группа.ПолучитьЭлементы();

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Запуск сеанса";
	Инструмент.ИмяФормы = "ЗапускСеанса";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Администрирование сервера";
	Инструмент.ИмяФормы = "АдминистрированиеСервера";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "История сеансов";
	Инструмент.ИмяФормы = "ИсторияСеансов";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Командная строка Windows (WScript.Shell)";
	Инструмент.ИмяФормы = "КоманднаяСтрока";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Объекты метаданных (список ""Все функции"")";
	Инструмент.ИмяФормы = "ОбъектыМетаданных";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Очистка кеша";
	Инструмент.ИмяФормы = "ОчисткаКеша";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Просмотр отчетов об ошибках";
	Инструмент.ИмяФормы = "ПросмотрОтчетовОбОшибках";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Работа с DBF-таблицами";
	Инструмент.ИмяФормы = "РаботаСDBF";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Расшифровка битой ссылки";
	Инструмент.ИмяФормы = "РасшифровкаБитойСсылки";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Регламентные задания";
	Инструмент.ИмяФормы = "РегламентныеЗадания";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Сравнение реквизитов объектов";
	Инструмент.ИмяФормы = "СравнениеРеквизитовОбъектов";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Удаление недопустимых символов XML в объекте";
	Инструмент.ИмяФормы = "УдалениеНедопустимыхСимволовXMLВОбъекте";

	Инструмент = СтрокиГруппы.Добавить();
	Инструмент.Наименование = "Файловый менеджер";
	Инструмент.ИмяФормы = "ФайловыйМенеджер";
	
	Если Объект.ЭкспериментальныеФункции Тогда
		Группа = Группы.Добавить();
		Группа.Наименование = "Служебные";
		Группа.ЭтоГруппа = Истина;
		Группа.Экспериментальный = Истина;
		СтрокиГруппы = Группа.ПолучитьЭлементы();

		Инструмент = СтрокиГруппы.Добавить();
		Инструмент.Наименование = "Редактор универсальных пакетов";
		Инструмент.ИмяФормы = "РедакторУниверсальныхПакетов";
		Инструмент.Экспериментальный = Истина;
	КонецЕсли;
КонецПроцедуры

// Передаёт клиенту информацию для обращения в техподдержку, которую можно получить только на сервере
//
&НаСервере
Функция ИнформацияДляТехподдержкиНаСервере()
	Результат = Новый Структура;
	Результат.Вставить("Конфигурация", Метаданные.Имя);
	Результат.Вставить("ВерсияКонфигурации", Метаданные.Версия);
	Результат.Вставить("РежимСовместимости", Строка(Метаданные.РежимСовместимости));
	Результат.Вставить("РежимСовместимостиИнтерфейса", Строка(Метаданные.РежимСовместимостиИнтерфейса));
	
	СистИнфо = Новый СистемнаяИнформация;
	Результат.Вставить("ОС", СистИнфо.ВерсияОС);
	Результат.Вставить("Процессор", СистИнфо.Процессор);
	Результат.Вставить("ОперативнаяПамять", СистИнфо.ОперативнаяПамять);
	
	Если СтрНачинаетсяС(НРег(СтрокаСоединенияИнформационнойБазы()), "srvr=") Тогда
		РежимРаботыИБ = "Клиент-серверный";
	ИначеЕсли СтрНачинаетсяС(НРег(СтрокаСоединенияИнформационнойБазы()), "file=") Тогда
		РежимРаботыИБ = "Файловый";
	ИначеЕсли СтрНачинаетсяС(НРег(СтрокаСоединенияИнформационнойБазы()), "ws=") Тогда
		РежимРаботыИБ = "Через веб-сервер";
	Иначе
		РежимРаботыИБ = "Неизвестный";
	КонецЕсли;
	
	Результат.Вставить("РежимРаботыИБ", РежимРаботыИБ);
	
	Возврат Результат;
КонецФункции

//
// Параметры:
//  Путь - Строка, Неопределено - Если Неопределено, красивый редактор будет распаковываться из макета
//         В качестве строки передаётся путь
//
&НаСервере
Процедура ЗаписатьПутьККрасивомуРедакторуКода(Знач Путь)
	РеквизитФормыВЗначение("Объект").СохранитьНастройку(Неопределено, "ПутьККрасивомуРедакторуКода", Путь);
КонецПроцедуры

&НаКлиенте
Асинх Процедура ПроверитьОбновленияАсинх()
	#Если Не ВебКлиент Тогда
		ЗаполненаПатчВерсия = (СтрРазделить(Объект.Версия, ".").Количество() = 3);
		Если Не ЗаполненаПатчВерсия Тогда
			Возврат;
		КонецЕсли;
		
		ТелоОтвета = Неопределено;
		Попытка
			Соединение = Новый HTTPСоединение("api.github.com", 443,,,, 5, Новый ЗащищенноеСоединениеOpenSSL);
			
			Запрос = Новый HTTPЗапрос("/repos/IgorRyaboff/Instrumentiki/releases");
			Запрос.Заголовки.Вставить("X-GitHub-Api-Version", "2022-11-28");
			Запрос.Заголовки.Вставить("Accept", "application/vnd.github+json");
			
			HTTPОтвет = Ждать Соединение.ПолучитьАсинх(Запрос);
			
			ЧтениеJSON = Новый ЧтениеJSON;
			ЧтениеJSON.УстановитьСтроку(HTTPОтвет.ПолучитьТелоКакСтроку());
			ТелоОтвета = ПрочитатьJSON(ЧтениеJSON);
			ЧтениеJSON.Закрыть();
		Исключение
			// Ничего не делаем
			Возврат;
		КонецПопытки;
		
		ЕстьОбновление = Ложь;
		Для Каждого ОписаниеВерсии Из ТелоОтвета Цикл
			НомерВерсии = ОписаниеВерсии.tag_name;
			ЭтоПредварительнаяВерсия = ОписаниеВерсии.prerelease;
			
			Если Не ЭтоПредварительнаяВерсия И СравнитьВерсии(Объект.Версия, НомерВерсии) = 1 Тогда
				ЕстьОбновление = Истина;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Если Не ЕстьОбновление Тогда
			Возврат;
		КонецЕсли;
		
		Текст = НСтр("ru='Доступно обновление Инструментиков! Нажмите, чтобы загрузить'");
		Элементы.ПроверитьНаличиеОбновлений.Заголовок = Текст;
		Элементы.ПроверитьНаличиеОбновлений.ЦветТекста = WebЦвета.Красный;
		
		СообщитьОНаличииОбновленияАсинх();
	#КонецЕсли
КонецПроцедуры

&НаКлиенте
Асинх Процедура СообщитьОНаличииОбновленияАсинх()
	Если Объект.НеНапоминатьОбОбновленииДо >= ТекущаяДатаСеансаССервера() Тогда
		Возврат;
	КонецЕсли;
	
	Кнопки = Новый СписокЗначений;
	Кнопки.Добавить("Обновить", НСтр("ru='Обновить'"));
	Если Объект.ПравоСохранениеНастроек Тогда
		Кнопки.Добавить("НеНапоминать", НСтр("ru='Скрыть на неделю'"));
	КонецЕсли;
	Кнопки.Добавить(КодВозвратаДиалога.Отмена, НСтр("ru='Закрыть'"));
	ТекстВопроса = НСтр("ru = 'Доступно обновление Инструментиков! Рекомендуется обновить обработку'");
	Ответ = Ждать ВопросАсинх(ТекстВопроса , Кнопки,, "Обновить");
		
	Если Ответ = "Обновить" Тогда
		ОткрытьФорму(Объект.ИмяМетаданныхОбработки + ".Форма.Главная_Обновление",
			Новый Структура("ТекущаяВерсия", Объект.Версия));
		//
	ИначеЕсли Ответ = "НеНапоминать" Тогда
		ЗаписатьДатуНеНапоминатьОбОбновлении();
		Состояние(НСтр("ru='Скрыли напоминания'"),, НСтр("ru='Встретимся через неделю :)'"));
	ИначеЕсли Ответ = КодВозвратаДиалога.Отмена Тогда
		Возврат;
	Иначе
		ВызватьИсключение "Некорректный ответ " + Ответ;
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ТекущаяДатаСеансаССервера()
	Возврат ТекущаяДатаСеанса();
КонецФункции

&НаСервере
Процедура ЗаписатьДатуНеНапоминатьОбОбновлении()
	Значение = КонецДня(ТекущаяДатаСеанса()) + (86400 * 7);
	РеквизитФормыВЗначение("Объект").СохранитьНастройку(Неопределено, "НеНапоминатьОбОбновленииДо", Значение);
КонецПроцедуры

&НаСервере
Процедура ЗаписатьНастройкуЭкспериментальныеФункции(Знач Значение)
	РеквизитФормыВЗначение("Объект").СохранитьНастройку(Неопределено, "ЭкспериментальныеФункции", Значение);
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ОчиститьВсеНастройкиИнструментиковНаСервере()
	Если Не ПравоДоступа("СохранениеДанныхПользователя", Метаданные) Тогда
		Возврат;
	КонецЕсли;
	
	Выборка = ХранилищеОбщихНастроек.Выбрать(Новый Структура("Пользователь", ИмяПользователя()));
	Пока Выборка.Следующий() Цикл
		Если Выборка.КлючОбъекта = "Инструментики" Или СтрНачинаетсяС(Выборка.КлючОбъекта, "Инструментики.") Тогда
			ХранилищеОбщихНастроек.Удалить(Выборка.КлючОбъекта, Неопределено, ИмяПользователя());
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Асинх Процедура ОтключитьЗащитуОтОпасныхДействийАсинх()
	ТекстВопроса = НСтр("ru='Отключить защиту от опасных действий для текущего пользователя?'");
	Ответ = Ждать ВопросАсинх(ТекстВопроса, РежимДиалогаВопрос.ДаНет);
	Если Ответ = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	ОтключитьЗащитуОтОпасныхДействийНаСервере();
	
	Кнопки = Новый СписокЗначений;
	Кнопки.Добавить(КодВозвратаДиалога.Да, НСтр("ru='Перезапустить сейчас'"));
	Кнопки.Добавить(КодВозвратаДиалога.Нет, НСтр("ru='Перезапустить позднее'"));
	Ответ = Ждать ВопросАсинх(НСтр("ru='Для вступления изменений в силу необходимо перезапустить программу'"), Кнопки);
	Если Ответ = КодВозвратаДиалога.Да Тогда
		ЗавершитьРаботуСистемы(Истина, Истина);
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ОтключитьЗащитуОтОпасныхДействийНаСервере()
	ПользовательИБ = ПользователиИнформационнойБазы.ТекущийПользователь();
	ПользовательИБ.ЗащитаОтОпасныхДействий.ПредупреждатьОбОпасныхДействиях = Ложь;
	ПользовательИБ.Записать();
КонецПроцедуры

&НаКлиенте
Асинх Процедура ОткрытьФормуИнструмента(ИмяФормыИнструмента, ПараметрыФормы = Неопределено, НовоеОкноБезЗапроса = Ложь)
	ИмяОткрываемойФормы = Объект.ИмяМетаданныхОбработки + ".Форма." + ИмяФормыИнструмента;
	
	ВыбраннаяФорма = Неопределено;
	Если Не НовоеОкноБезЗапроса Тогда
		ОткрытыеОкна = СписокВыбораФормыИнструмента(ИмяОткрываемойФормы);
		Если ОткрытыеОкна.Количество() > 0 Тогда
			ВыбранныйЭлемент = Ждать ОткрытыеОкна.ВыбратьЭлементАсинх(НСтр("ru = 'Выберите окно'; en = 'Choose a window'"));
			Если ВыбранныйЭлемент <> Неопределено Тогда
				ВыбраннаяФорма = ВыбранныйЭлемент.Значение;
			Иначе
				Возврат;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если ВыбраннаяФорма <> Неопределено Тогда
		ВыбраннаяФорма.Активизировать();
	Иначе
		ОткрытьФорму(ИмяОткрываемойФормы, ПараметрыФормы,, Строка(Новый УникальныйИдентификатор));
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Функция СписокВыбораФормыИнструмента(ИмяОткрываемойФормы)
	ОткрытыеОкна = Новый СписокЗначений;
	ОкнаПриложения = ПолучитьОкна();
	Для Каждого ОкноПриложения Из ОкнаПриложения Цикл
		Для Каждого Форма Из ОкноПриложения.Содержимое Цикл
			Если Форма.ИмяФормы = ИмяОткрываемойФормы Тогда
				ОткрытыеОкна.Добавить(Форма, Форма.Заголовок);
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Если ОткрытыеОкна.Количество() > 0 Тогда
		ОткрытыеОкна.Вставить(0, Неопределено, НСтр("ru = '<Новое окно>'; en = '<New window>'"));
	КонецЕсли;
	
	Возврат ОткрытыеОкна;
КонецФункции

#КонецОбласти
