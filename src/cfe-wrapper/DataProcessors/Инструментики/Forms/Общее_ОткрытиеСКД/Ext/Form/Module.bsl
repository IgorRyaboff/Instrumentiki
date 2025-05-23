﻿
// --------------------------------------------------------------------------------
// Copyright (c) 2024-2025 Igor Ryabov (https://github.com/IgorRyaboff/Instrumentiki)
// License: https://github.com/IgorRyaboff/Instrumentiki/blob/main/LICENSE
// --------------------------------------------------------------------------------

#Область ОписаниеПеременных

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Объект.БезопасныйРежим Тогда
		Элементы.ИсточникВнешнийОтчет.Доступность = Ложь;
		Элементы.ИсточникВнешнийОтчет.Подсказка = НСтр("ru='Недоступно в безопасном режиме'");
	КонецЕсли;
	
	Параметры.Свойство("АдресДанныхАвтосохранения", АдресДанныхАвтосохранения);
	Если ЗначениеЗаполнено(АдресДанныхАвтосохранения) Тогда
		Источник = "ДанныеАвтосохранения"
	Иначе
		Источник = "XML";
		Элементы.ИсточникДанныеАвтосохранения.Видимость = Ложь;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы
// Код процедур и функций
#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Асинх Процедура Далее(Команда)
	Если Источник = "ДанныеАвтосохранения" Тогда
		ХранилищеСКД = ХранилищеСКДИзДанныхАвтосохранения(АдресДанныхАвтосохранения);
		ЗакрытьФормуСРезультатом(ХранилищеСКД, "Из данных автосохранения");
	ИначеЕсли Источник = "XML" Тогда
		ПараметрыДиалога = Новый ПараметрыДиалогаПомещенияФайлов(, Ложь, "Схема компоновки данных (*.xml)|*.xml");
		ОписаниеПомещенногоФайла = Ждать ПоместитьФайлНаСерверАсинх(,,, ПараметрыДиалога, УникальныйИдентификатор);
		Если ОписаниеПомещенногоФайла = Неопределено Тогда
			Возврат;
		КонецЕсли;
		
		ХранилищеСКД = ХранилищеСКДИзXMLФайла(ОписаниеПомещенногоФайла.Адрес);
		ЗакрытьФормуСРезультатом(ХранилищеСКД, "Файл " + ОписаниеПомещенногоФайла.СсылкаНаФайл.Имя);
	ИначеЕсли Источник = "ВнешнийОтчет" Тогда
		ТекстВопроса = "Вы собираетесь подключить внешний программный код.
		               |Рекомендуется обращать внимание на источник, из которого был получен файл. Если вы не уверены в содержимом этого файла или в источнике, то файл не рекомендуется подключать к программе.
	                   |См. также: ";
		ТекстВопроса = Новый ФорматированнаяСтрока(ТекстВопроса, Новый ФорматированнаяСтрока("Пример проблемы с вирусом во внешней обработке",,,, "https://1c.ru/news/info.jsp?id=21537"));
		
		Кнопки = Новый СписокЗначений;
		Кнопки.Добавить(КодВозвратаДиалога.Да, "Продолжить");
		Кнопки.Добавить(КодВозвратаДиалога.Нет, "Отмена");
		Ответ = Ждать ВопросАсинх(ТекстВопроса, Кнопки,,, "Опасность! Внешний код!");
		Если Ответ = КодВозвратаДиалога.Нет Тогда
			Возврат;
		КонецЕсли;
		
		ПараметрыДиалога = Новый ПараметрыДиалогаПомещенияФайлов(, Ложь, "Внешний отчет (*.erf)|*.erf");
		ОписаниеПомещенногоФайла = Ждать ПоместитьФайлНаСерверАсинх(,,, ПараметрыДиалога, УникальныйИдентификатор);
		Если ОписаниеПомещенногоФайла = Неопределено Тогда
			Возврат;
		КонецЕсли;
		
		Результат = ХранилищеСКДИзВнешнегоОтчета(ОписаниеПомещенногоФайла.Адрес);
		Если ЗначениеЗаполнено(Результат.ОписаниеОшибки) Тогда
			ПоказатьПредупреждение(, Результат.ОписаниеОшибки,, "Возникла ошибка");
			Возврат;
		КонецЕсли;
		
		ЗакрытьФормуСРезультатом(Результат.ХранилищеСКД, "Внешний отчет " + ОписаниеПомещенногоФайла.СсылкаНаФайл.Имя);
	ИначеЕсли Источник = "ОтчетКонфигурации" Тогда
		СписокЗначений = Новый СписокЗначений;
		СписокЗначений.ЗагрузитьЗначения(ОтчетыКонфигурации());
		
		ПараметрыФормы = Новый Структура("Список, Режим", СписокЗначений, "ВыборЭлемента");
		ОповещениеОЗакрытии = Новый ОписаниеОповещения("ПослеВыбораОтчетаКонфигурации", ЭтотОбъект);
		ОткрытьФорму(Объект.ИмяМетаданныхОбработки + ".Форма.Общая_СписокЗначений", ПараметрыФормы,,,,, ОповещениеОЗакрытии);
	ИначеЕсли Источник = "ДополнительныйОтчет" Тогда
		Попытка
			Тип = Тип("СправочникСсылка.ДополнительныеОтчетыИОбработки");
		Исключение
			ПоказатьПредупреждение(, "Доступно только для конфигураций с БСП");
			Возврат;
		КонецПопытки;
		
		ОповещениеОЗакрытии = Новый ОписаниеОповещения("ПослеВыбораДополнительногоОтчета", ЭтотОбъект);
		ОткрытьФорму("Справочник.ДополнительныеОтчетыИОбработки.ФормаВыбора",,,,,, ОповещениеОЗакрытии);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	Закрыть();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Функция ХранилищеСКДИзДанныхАвтосохранения(АдресВоВременномХранилище)
	СКД = ПолучитьИзВременногоХранилища(АдресВоВременномХранилище);
	Возврат Новый ХранилищеЗначения(СКД);
КонецФункции

&НаСервереБезКонтекста
Функция ХранилищеСКДИзXMLФайла(АдресВоВременномХранилище)
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресВоВременномХранилище);
	XML = ПолучитьСтрокуИзДвоичныхДанных(ДвоичныеДанные);
	
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.УстановитьСтроку(XML);
	
	СКД = СериализаторXDTO.ПрочитатьXML(ЧтениеXML, Тип("СхемаКомпоновкиДанных"));
	Возврат Новый ХранилищеЗначения(СКД);
КонецФункции

&НаСервереБезКонтекста
Функция ХранилищеСКДИзВнешнегоОтчета(АдресВоВременномХранилище)
	Результат = Новый Структура("ХранилищеСКД, ОписаниеОшибки", "", "");
	
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла("erf");
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресВоВременномХранилище);
	УдалитьИзВременногоХранилища(АдресВоВременномХранилище);
	ДвоичныеДанные.Записать(ИмяВременногоФайла);
	
	СлучайнаяСтрока = СтрЗаменить(ВРег(Строка(Новый УникальныйИдентификатор)), "-", "");
	ИмяОтчета = "ИнструментикиВнешнийОтчет" + СлучайнаяСтрока;
	
	Попытка
		ВнешнийОтчет = ВнешниеОтчеты.Создать(ИмяВременногоФайла);
	Исключение
		Результат.ОписаниеОшибки = ОписаниеОшибки();
		ВнешнийОтчет = Неопределено;
	КонецПопытки;
	
	УдалитьФайлы(ИмяВременногоФайла);
	
	Если ВнешнийОтчет = Неопределено Тогда
		// Текст описания ошибки на этом моменте уже установлен
		Возврат Результат;
	КонецЕсли;
	
	СКД = ВнешнийОтчет.СхемаКомпоновкиДанных;
	Если СКД = Неопределено Тогда
		Результат.ОписаниеОшибки = "У внешнего отчета не заполнена ""Основная схема компоновки данных""
		                           |Откройте требующуюся СКД в конфигураторе и выгрузите её вручную";
		Возврат Результат;
	КонецЕсли;
	
	Результат.ХранилищеСКД = Новый ХранилищеЗначения(СКД);
	Возврат Результат;
КонецФункции

&НаСервереБезКонтекста
Функция ХранилищеСКДИзОтчетаКонфигурации(Имя)
	Результат = Новый Структура("ХранилищеСКД, ОписаниеОшибки", "", "");
	
	МетаданныеОтчета = Метаданные.Отчеты[Имя];
	Если МетаданныеОтчета.ОсновнаяСхемаКомпоновкиДанных = Неопределено Тогда
		Результат.ОписаниеОшибки = "У отчета не заполнена ""Основная схема компоновки данных""
		                           |Откройте требующуюся СКД в конфигураторе и выгрузите её вручную";
		Возврат Результат;
	КонецЕсли;
	
	СКД = Отчеты[Имя].ПолучитьМакет(МетаданныеОтчета.ОсновнаяСхемаКомпоновкиДанных.Имя);
	Результат.ХранилищеСКД = Новый ХранилищеЗначения(СКД);
	Возврат Результат;
КонецФункции

&НаСервереБезКонтекста
Функция ХранилищеСКДИзДополнительногоОтчета(Ссылка)
	Результат = Новый Структура("ХранилищеСКД, ОписаниеОшибки", "", "");
	
	НавигационнаяСсылкаХранилищаОтчета = ПолучитьНавигационнуюСсылку(Ссылка, "ХранилищеОбработки");
	
	ВременноеИмя = "ВременноПодключенныйОтчет_" + СтрЗаменить(Строка(Новый УникальныйИдентификатор), "-", "");
	Попытка
		ВнешниеОтчеты.Подключить(НавигационнаяСсылкаХранилищаОтчета, ВременноеИмя);
		ВнешнийОтчет = ВнешниеОтчеты.Создать(ВременноеИмя);
	Исключение
		Результат.ОписаниеОшибки = ОписаниеОшибки();
		Возврат Результат;
	КонецПопытки;
	
	СКД = ВнешнийОтчет.СхемаКомпоновкиДанных;
	Если СКД = Неопределено Тогда
		Результат.ОписаниеОшибки = "У дополнительного отчета не заполнена ""Основная схема компоновки данных""
		                           |Откройте требующуюся СКД в конфигураторе и выгрузите её вручную";
		Возврат Результат;
	КонецЕсли;
	
	Результат.ХранилищеСКД = Новый ХранилищеЗначения(СКД);
	Возврат Результат;
КонецФункции

&НаСервереБезКонтекста
Функция ОтчетыКонфигурации() 
	Результат = Новый Массив;
	
	Для Каждого Мета Из Метаданные.Отчеты Цикл
		Результат.Добавить(Мета.Имя);
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

&НаКлиенте
Процедура ПослеВыбораОтчетаКонфигурации(ИмяОтчета, ДополнительныеПараметры) Экспорт
	Если ИмяОтчета = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Результат = ХранилищеСКДИзОтчетаКонфигурации(ИмяОтчета);
	Если ЗначениеЗаполнено(Результат.ОписаниеОшибки) Тогда
		ПоказатьПредупреждение(, Результат.ОписаниеОшибки,, "Возникла ошибка");
		Возврат;
	КонецЕсли;
	
	ЗакрытьФормуСРезультатом(Результат.ХранилищеСКД, "Отчет конфигурации: " + ИмяОтчета);
КонецПроцедуры

&НаКлиенте
Процедура ЗакрытьФормуСРезультатом(ХранилищеСКД, Заголовок = "")
	Закрыть(Новый Структура("ХранилищеСКД, Заголовок", ХранилищеСКД, Заголовок));
КонецПроцедуры

// Обработчик закрытия формы выбора доп. отчета БСП
//
// Параметры:
//  Ссылка - СправочникСсылка.ДополнительныеОтчетыИОбработки, Неопределено - Выбранный элемент
//  ДополнительныеПараметры - Произвольный - Не используется данной процедурой
&НаКлиенте
Процедура ПослеВыбораДополнительногоОтчета(Ссылка, ДополнительныеПараметры) Экспорт
	Если Ссылка = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Результат = ХранилищеСКДИзДополнительногоОтчета(Ссылка);
	Если ЗначениеЗаполнено(Результат.ОписаниеОшибки) Тогда
		ПоказатьПредупреждение(, Результат.ОписаниеОшибки,, "Возникла ошибка");
		Возврат;
	КонецЕсли;
	
	ЗакрытьФормуСРезультатом(Результат.ХранилищеСКД, "Доп. отчет: " + Строка(Ссылка));
КонецПроцедуры

#КонецОбласти
