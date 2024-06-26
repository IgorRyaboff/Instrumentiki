﻿
// --------------------------------------------------------------------------------
// Copyright (c) 2024 Igor Ryabov (https://github.com/IgorRyaboff/Instrumentiki)
// License: https://github.com/IgorRyaboff/Instrumentiki/blob/main/LICENSE
// --------------------------------------------------------------------------------

#Область ОбработчикиСобытийФормы
// Код процедур и функций
#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы
// Код процедур и функций
#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Асинх Процедура ПолучитьСсылкуПоНавигационной(Команда)
	Ссылка = Ждать ОткрОб_ЗапроситьСсылкуИзНавигационнойАсинх();
	Если Ссылка <> Неопределено Тогда
		ПоказатьПредупреждение(, Строка(Ссылка));
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Асинх Процедура ПолучитьСсылкуИзОткрытыхОкон(Команда)
	Ссылка = Ждать ОткрОб_ЗапроситьСсылкуИзОткрытыхОконАсинх();
	Если Ссылка <> Неопределено Тогда
		ПоказатьПредупреждение(, Строка(Ссылка));
	КонецЕсли;
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

#КонецОбласти
