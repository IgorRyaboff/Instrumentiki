﻿
// --------------------------------------------------------------------------------
// Copyright (c) 2024 Igor Ryabov (https://github.com/IgorRyaboff/Instrumentiki)
// License: https://github.com/IgorRyaboff/Instrumentiki/blob/main/LICENSE
// --------------------------------------------------------------------------------

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ЗаполнитьТаблицуПСНаСервере();
	Элементы.ПривилегированныйРежим.Доступность = Не БезопасныйРежим();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыТаблицаПС

&НаКлиенте
Процедура ТаблицаПСЗначениеПриИзменении(Элемент)
	ТекущиеДанные = Элементы.ТаблицаПС.ТекущиеДанные;
	УстановитьНовоеЗначениеПС(ТекущиеДанные.Имя, ТекущиеДанные.Значение, ПривилегированныйРежим);
	Состояние("Значение установлено",, ТекущиеДанные.Синоним);
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаКонстантВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаПСПередНачаломИзменения(Элемент, Отказ)
	ТекДанные = Элемент.ТекущиеДанные;
	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ТекДанные.НередактируемыйТип Тогда
		Отказ = Истина;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОбновитьТаблицуПС(Команда)
	ТаблицаПС.Очистить();
	ЗаполнитьТаблицуПСНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура РедактироватьВКонсолиКода(Команда)
	ТекДанные = Элементы.ТаблицаПС.ТекущиеДанные;
	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ЭтоХранилищеЗначения = (ТипЗнч(ТекДанные.Значение) = Тип("ХранилищеЗначения"));
	
	ШаблонКода = "Значение = ПараметрыСеанса.%1%2;
	             |
				 |// Обработка значения
				 |
				 |ПараметрыСеанса.%1 = %3;";
	Код = СтрШаблон(ШаблонКода, ТекДанные.Имя, ?(ЭтоХранилищеЗначения, ".Получить()", ""), ?(ЭтоХранилищеЗначения, "Новый ХранилищеЗначения(Значение)", "Значение"));
	
	ПараметрыФормы = Новый Структура("Код, НаКлиенте", Код, Ложь);
	ОткрытьФорму("ВнешняяОбработка.Инструментики.Форма.КонсольКода", ПараметрыФормы);
КонецПроцедуры

&НаКлиенте
Процедура СортироватьВозр(Команда)
	СортироватьТаблицуЗначений("ТаблицаПС", "Возр");
КонецПроцедуры

&НаКлиенте
Процедура СортироватьУбыв(Команда)
	СортироватьТаблицуЗначений("ТаблицаПС", "Убыв");
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Устанавливает значение параметра сеанса
//
// Параметры:
//  Имя - Строка - Имя параметра сеанса
//  Значение - Произвольный - Значение параметра сеанса
//  ПривРежим - Булево - Если Истина, то установка значения будет выполнена в привилегированном режиме
&НаСервереБезКонтекста
Процедура УстановитьНовоеЗначениеПС(Имя, Значение, ПривРежим)
	Если ПривРежим Тогда
		УстановитьПривилегированныйРежим(Истина);
	КонецЕсли;
	ПараметрыСеанса[Имя] = Значение;
КонецПроцедуры

// Заполняет таблицу формы ТаблицаПС
//
&НаСервере
Процедура ЗаполнитьТаблицуПСНаСервере()
	Если ПривилегированныйРежим Тогда
		УстановитьПривилегированныйРежим(Истина);
	КонецЕсли;
	
	Для Каждого ПС Из Метаданные.ПараметрыСеанса Цикл
		Стр = ТаблицаПС.Добавить();
		Стр.Имя = ПС.Имя;
		Стр.Синоним = ПС.Синоним;
		Попытка
			ЗначениеПС = ПараметрыСеанса[ПС.Имя];
			Если ТипЗнч(ЗначениеПС) = Тип("ХранилищеЗначения")
				Или ТипЗнч(ЗначениеПС) = Тип("ДвоичныеДанные")
				Или ТипЗнч(ЗначениеПС) = Тип("Null")
				Или ТипЗнч(ЗначениеПС) = Тип("ОписаниеТипов")
				Или ТипЗнч(ЗначениеПС) = Тип("ФиксированныйМассив")
				Или ТипЗнч(ЗначениеПС) = Тип("ФиксированнаяСтруктура")
				Или ТипЗнч(ЗначениеПС) = Тип("ФиксированноеСоответствие") Тогда
				Стр.Значение = Неопределено;
				Стр.НередактируемыйТип = Истина;
			Иначе
				Стр.Значение = ЗначениеПС;
			КонецЕсли;
				
			Стр.Тип = Строка(ТипЗнч(ЗначениеПС));
			Если ТипЗнч(ЗначениеПС) = Тип("ХранилищеЗначения") Тогда
				Стр.Тип = Стр.Тип + СтрШаблон(" (%1)", ТипЗнч(Стр.Значение.Получить()));
			КонецЕсли;
		Исключение
			Стр.Значение = Неопределено;
			Стр.ОшибкаПолучения = Истина;
		КонецПопытки;
	КонецЦикла;
КонецПроцедуры

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
