﻿
// --------------------------------------------------------------------------------
// Copyright (c) 2024 Igor Ryabov (https://github.com/IgorRyaboff/Instrumentiki)
// License: https://github.com/IgorRyaboff/Instrumentiki/blob/main/LICENSE
// --------------------------------------------------------------------------------

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Элементы.ПривилегированныйРежим.Доступность = Не БезопасныйРежим();
	
	ОграничениеТипаВсеСсылки = ОграничениеТипаВсеСсылки();
	Элементы.ЛевоеЗначение.ОграничениеТипа = ОграничениеТипаВсеСсылки;
	Элементы.ПравоеЗначение.ОграничениеТипа = ОграничениеТипаВсеСсылки;
	
	Если Параметры.Ссылки <> Неопределено Тогда
		СсылкаСлева = Параметры.Ссылки[0];
		СсылкаСправа = Параметры.Ссылки[1];
		ПеречитатьОбъектыНаСервере();
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СсылкаСлеваПриИзменении(Элемент)
	Если ТипЗнч(СсылкаСлева) <> ТипЗнч(СсылкаСправа) Тогда
		СсылкаСправа = Новый(ТипЗнч(СсылкаСлева));
	КонецЕсли;
	
	ПеречитатьОбъектыНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ПравоеЗначениеПриИзменении(Элемент)
	ПеречитатьОбъектыНаСервере();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыРеквизитыОбъектов
// Код процедур и функций
#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПоменятьЛевоеПравоеМестами(Команда)
	Если Не ЗначениеЗаполнено(СсылкаСлева) И Не ЗначениеЗаполнено(СсылкаСправа) Тогда
		Возврат;
	КонецЕсли;
	
	НовоеЛево = ?(ЗначениеЗаполнено(СсылкаСправа), СсылкаСправа, Новый(ТипЗнч(СсылкаСлева)));
	НовоеПраво = СсылкаСлева;
	
	СсылкаСлева = НовоеЛево;
	СсылкаСправа = НовоеПраво;
	
	ПеречитатьОбъектыНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура УстановитьОтображениеТолькоРазличающихся(Команда)
	ПоказыватьТолькоРазличающиеся = Не ПоказыватьТолькоРазличающиеся;
	Элементы.РеквизитыОбъектовУстановитьОтображениеТолькоРазличающихся.Пометка = ПоказыватьТолькоРазличающиеся;
	
	Отбор = ?(ПоказыватьТолькоРазличающиеся, Новый ФиксированнаяСтруктура("ЗначенияРавны", Ложь), Неопределено);
	Элементы.РеквизитыОбъектов.ОтборСтрок = Отбор;
КонецПроцедуры

&НаКлиенте
Процедура СортироватьВозр(Команда)
	СортироватьТаблицуЗначений("РеквизитыОбъектов", "Возр");
КонецПроцедуры

&НаКлиенте
Процедура СортироватьУбыв(Команда)
	СортироватьТаблицуЗначений("РеквизитыОбъектов", "Убыв");
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьЛевоеЗначениеИзНавигационнойСсылки(Команда)
	ВызватьУстановкуЗначенияИзНавигационнойСсылкиАсинх("СсылкаСлева");
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПравоеЗначениеИзНавигационнойСсылки(Команда)
	ВызватьУстановкуЗначенияИзНавигационнойСсылкиАсинх("СсылкаСправа");
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьЛевоеЗначениеИзОкна(Команда)
	ВызватьУстановкуЗначенияИзОткрытыхОконАсинх("СсылкаСлева");
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПравоеЗначениеИзОкна(Команда)
	ВызватьУстановкуЗначенияИзОткрытыхОконАсинх("СсылкаСправа");
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ОткрытиеОбъектов1

// Запрашивает у пользователя навигационную ссылку и возвращает ссылку на объект ИБ
// При возникновении ошибки разбора ссылки формируется предупреждение
//
// Возвращаемое значение:
//  ЛюбаяСсылка, Неопределено -
&НаКлиенте
Асинх Функция ОткрОб_ЗапроситьСсылкуИзНавигационнойАсинх()
	ТекстСсылки = Ждать ВвестиСтрокуАсинх(Неопределено, НСтр("ru='Навигационная ссылка'"));
	Если ТекстСсылки = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Попытка
		Ссылка = ОткрОб_СсылкаИзНавигационной(ТекстСсылки);
		Возврат Ссылка;
	Исключение
		Ждать ПредупреждениеАсинх(НСтр("ru='Ошибка получения ссылки'"));
		Возврат Неопределено;
	КонецПопытки;
КонецФункции

// Запрашивает выбор пользователем открытого окна программы и возвращает соответствующую окну ссылку на объект ИБ
// При возникновении ошибки разбора ссылки формируется предупреждение
//
// Возвращаемое значение:
//  ЛюбаяСсылка, Неопределено -
&НаКлиенте
Асинх Функция ОткрОб_ЗапроситьСсылкуИзОткрытыхОконАсинх()
	Окна = ПолучитьОкна();
	СписокДляВыбора = Новый СписокЗначений;
	
	Для Каждого ОткрытоеОкно Из Окна Цикл
		Если ОткрытоеОкно.НачальнаяСтраница Тогда
			Продолжить;
		КонецЕсли;
		Если Не ЗначениеЗаполнено(ОткрытоеОкно.ПолучитьНавигационнуюСсылку()) Тогда
			Продолжить;
		КонецЕсли;
		
		СписокДляВыбора.Добавить(ОткрытоеОкно.ПолучитьНавигационнуюСсылку(), ОткрытоеОкно.Заголовок);
	КонецЦикла;
	
	Если СписокДляВыбора.Количество() = 0 Тогда
		ПоказатьПредупреждение(, НСтр("ru='Нет доступных для выбора окон'"));
		Возврат Неопределено;
	КонецЕсли;
	
	ВыбранныйЭлемент = Ждать СписокДляВыбора.ВыбратьЭлементАсинх(НСтр("ru='Выберите окно'"));
	Если ВыбранныйЭлемент = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Попытка
		Ссылка = ОткрОб_СсылкаИзНавигационной(ВыбранныйЭлемент.Значение);
		Возврат Ссылка;
	Исключение
		Ждать ПредупреждениеАсинх(НСтр("ru='Ошибка получения ссылки'"));
		Возврат Неопределено;
	КонецПопытки;
КонецФункции

// Формирует ссылку на объект ИБ из навигационной ссылки вида "e1cib/data/Справочник.Контрагенты?ref=80a700155d116f0111ea5a82d06033f4"
// При невозможности сформировать ссылку вызывает исключение
//
// Параметры:
//  НавигационнаяСсылка - Строка -
//
// Возвращаемое значение:
//  Произвольный - Ссылка на объект ИБ
&НаСервереБезКонтекста
Функция ОткрОб_СсылкаИзНавигационной(Знач НавигационнаяСсылка)
	ПерваяТочка = Найти(НавигационнаяСсылка, "e1cib/data/");
    ВтораяТочка = Найти(НавигационнаяСсылка, "?ref=");
    
    ПредставлениеТипа = Сред(НавигационнаяСсылка, ПерваяТочка + 11, ВтораяТочка - ПерваяТочка - 11);
    ШаблонЗначения = ЗначениеВСтрокуВнутр(ПредопределенноеЗначение(ПредставлениеТипа + ".ПустаяСсылка"));
    ЗначениеСсылки = СтрЗаменить(ШаблонЗначения, "00000000000000000000000000000000", Сред(НавигационнаяСсылка, ВтораяТочка + 5));
	Возврат ЗначениеИзСтрокиВнутр(ЗначениеСсылки);
КонецФункции

#КонецОбласти

&НаКлиенте
Асинх Процедура ВызватьУстановкуЗначенияИзНавигационнойСсылкиАсинх(ИмяРеквизита)
	НоваяСсылка = Ждать ОткрОб_ЗапроситьСсылкуИзНавигационнойАсинх();
	Если НоваяСсылка <> Неопределено Тогда
		ЭтотОбъект[ИмяРеквизита] = НоваяСсылка;
		ПеречитатьОбъектыНаСервере();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Асинх Процедура ВызватьУстановкуЗначенияИзОткрытыхОконАсинх(ИмяРеквизита)
	НоваяСсылка = Ждать ОткрОб_ЗапроситьСсылкуИзОткрытыхОконАсинх();
	Если НоваяСсылка <> Неопределено Тогда
		ЭтотОбъект[ИмяРеквизита] = НоваяСсылка;
		ПеречитатьОбъектыНаСервере();
	КонецЕсли;
КонецПроцедуры

// Перечитать оба объекта и перезаполнить данные формы
//
&НаСервере
Процедура ПеречитатьОбъектыНаСервере()
	Если ПривилегированныйРежим Тогда
		УстановитьПривилегированныйРежим(Истина);
	КонецЕсли;
	
	РеквизитыОбъектов.Очистить();
	Если Не ЗначениеЗаполнено(СсылкаСлева) Тогда
		Возврат;
	КонецЕсли;
	
	Мета = СсылкаСлева.Метаданные();
	ЛевыйОбъект = СсылкаСлева.ПолучитьОбъект();
	Если ЗначениеЗаполнено(СсылкаСправа) Тогда
		ПравыйОбъект = СсылкаСправа.ПолучитьОбъект();
	Иначе
		ПравыйОбъект = Неопределено;
	КонецЕсли;
	
	Для Каждого Рекв Из ВсеРеквизитыОбъектаМетаданных(Мета, "СтандартныеРеквизиты, Реквизиты") Цикл
		Стр = РеквизитыОбъектов.Добавить();
		Стр.Имя = Рекв.Имя;
		Стр.ОписаниеТипов = Строка(Рекв.Тип);
		Стр.Синоним = Рекв.Синоним;
		ЗначениеСлева = ЛевыйОбъект[Рекв.Имя];
		Стр.ТипСлева = Строка(ТипЗнч(ЗначениеСлева));
		Стр.ЗначениеСлева = ЗначениеСлева;
		
		Если ЗначениеЗаполнено(СсылкаСправа) Тогда
			ЗначениеСправа = ПравыйОбъект[Рекв.Имя];
			Стр.ТипСправа = Строка(ТипЗнч(ЗначениеСправа));
			Стр.ЗначениеСправа = ЗначениеСправа;
			
			Если ТипЗнч(ЗначениеСлева) = ТипЗнч(ЗначениеСправа) Тогда
				Если ТипЗнч(ЗначениеСлева) = Тип("ХранилищеЗначения") Тогда
					Стр.ЗначенияРавны = (XMLСтрока(ЗначениеСлева) = XMLСтрока(ЗначениеСправа));
				Иначе
					Стр.ЗначенияРавны = (ЗначениеСлева = ЗначениеСправа);
				КонецЕсли;
			Иначе
				Стр.ЗначенияРавны = Ложь;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

// Получить список всех реквизитов объекта метаданных, включая стандартные
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных -
//  ИменаКоллекцийРеквизитов - Строка - Перечисленные через запятую имена свойств, являющихся коллекциями реквизитов. Например, "СтандартныеРеквизиты, Реквизиты"
//
// Возвращаемое значение:
//  Массив - Массив значений типа ОбъектМетаданных (реквизит)
&НаСервереБезКонтекста
Функция ВсеРеквизитыОбъектаМетаданных(ОбъектМетаданных, ИменаКоллекцийРеквизитов)
	Результат = Новый Массив;
	
	Для Каждого ИмяКоллекции Из СтрРазделить(ИменаКоллекцийРеквизитов, ",") Цикл
		Для Каждого Реквизит Из ОбъектМетаданных[СокрЛП(ИмяКоллекции)] Цикл
			Если ИмяКоллекции = "СтандартныеРеквизиты" И (Реквизит.Имя = "Ссылка" Или Реквизит.Имя = "Регистратор") Тогда
				Продолжить;
			КонецЕсли;
			Результат.Добавить(Реквизит);
		КонецЦикла;
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

// Формирует ОписаниеТипов, содержащее все типы всех ссылочных объектов, которые можно создавать в режиме Предприятия
// Необходимо для включения типов из расширений в ограничение типа
//
// Возвращаемое значение:
//  ОписаниеТипов
&НаСервереБезКонтекста
Функция ОграничениеТипаВсеСсылки()
	ОграничениеТипа = Новый ОписаниеТипов;
	ОграничениеТипа = ОписаниеТиповКоллекцииОбъектовМетаданных(ОграничениеТипа, Метаданные.Справочники, "СправочникСсылка");
	ОграничениеТипа = ОписаниеТиповКоллекцииОбъектовМетаданных(ОграничениеТипа, Метаданные.Документы, "ДокументСсылка");
	ОграничениеТипа = ОписаниеТиповКоллекцииОбъектовМетаданных(ОграничениеТипа, Метаданные.ПланыВидовХарактеристик, "ПланВидовХарактеристикСсылка");
	ОграничениеТипа = ОписаниеТиповКоллекцииОбъектовМетаданных(ОграничениеТипа, Метаданные.ПланыВидовРасчета, "ПланВидовРасчетаСсылка");
	ОграничениеТипа = ОписаниеТиповКоллекцииОбъектовМетаданных(ОграничениеТипа, Метаданные.БизнесПроцессы, "БизнесПроцессСсылка");
	ОграничениеТипа = ОписаниеТиповКоллекцииОбъектовМетаданных(ОграничениеТипа, Метаданные.Задачи, "ЗадачаСсылка");
	ОграничениеТипа = ОписаниеТиповКоллекцииОбъектовМетаданных(ОграничениеТипа, Метаданные.ПланыОбмена, "ПланОбменаСсылка");
	Возврат ОграничениеТипа;
КонецФункции

// Добавляет в ИсходноеОписаниеТипов все типы из коллекции Коллекция
//
// Параметры:
//  ИсходноеОписаниеТипов - ОписаниеТипов -
//  Коллекция - КоллекцияОбъектовМетаданных -
//  Префикс - Строка - Префикс для имени типа. Например, для справочников следует передать "СправочникСсылка"
//
// Возвращаемое значение:
//  ОписаниеТипов -
&НаСервереБезКонтекста
Функция ОписаниеТиповКоллекцииОбъектовМетаданных(ИсходноеОписаниеТипов, Коллекция, Префикс)
	ДобавляемыеТипы = Новый Массив;
	Для Каждого Объект Из Коллекция Цикл
		ДобавляемыеТипы.Добавить(СтрШаблон("%1.%2", Префикс, Объект.Имя));
	КонецЦикла;
	
	Результат = Новый ОписаниеТипов(ИсходноеОписаниеТипов, СтрСоединить(ДобавляемыеТипы, ", "));
	Возврат Результат;
КонецФункции

// Универсальная процедура сортировки таблицы значений
//
// Параметры:
//  ИмяТаблицыФормы - Строка - Имя элемента формы, ссылающегося на таблицу
//  Направление - Строка - "Возр" или "Убыв"
&НаСервере
Процедура СортироватьТаблицуЗначений(ИмяТаблицыФормы, Направление)
	ТаблицаФормы = Элементы[ИмяТаблицыФормы];
	ПрефиксПутиКДанным = ТаблицаФормы.ПутьКДанным + ".";
	
	ТекущаяКолонка = ТаблицаФормы.ТекущийЭлемент;
	ИмяКолонки = СтрЗаменить(ТекущаяКолонка.ПутьКДанным, ПрефиксПутиКДанным, "");
	
	ЭтотОбъект[ТаблицаФормы.ПутьКДанным].Сортировать(ИмяКолонки + " " + Направление);
КонецПроцедуры

#КонецОбласти
