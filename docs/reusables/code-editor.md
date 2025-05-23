# Красивый редактор

Красивый редактор - это механизм подключения HTML-редактора кода для редактирования кода на встроенном языке 1С, а также на языке запросов.

# Внедрение красивого редактора

## Создание команд и кнопок на форме

На форме следует создать строковый реквизит неограниченной длины с именем `УМ_КрасивыйРедакторКода_Путь`.

На форме следует создать по два элемента для каждого редактируемого реквизита с кодом:
- "Простой" элемент (например, с текстовым документом). Путь к данным - сам реквизит с кодом;
- Поле HTML-документа. Путь к данным - реквизит `УМ_КрасивыйРедакторКода_Путь`.

На форме следует создать команду для переключения редактора кода. Ее обработчик должен выполнять вызов по шаблону:

```1c
&НаКлиенте
Процедура ПереключитьРедакторКода(Команда)
	УМ_КрасивыйРедактор_ПереключитьРедакторКода(Элементы.ФормаПереключитьРедакторКода);
КонецПроцедуры
```

## Подключение обработчиков событий формы

В обработчике `ПриСозданииНаСервере` следует вставить вызов процедуры по шаблону:

```1c
УМ_КрасивыйРедактор_ПриСозданииНаСервере();
```

## Наполнение переопределяемых методов

Следует наполнить кодом следующие методы из области `СлужебныеПроцедурыИФункции`:
- `УМ_КрасивыйРедактор_ПриОпределенииРедакторовПереопределяемый`
