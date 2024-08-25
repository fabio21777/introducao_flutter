# Gerenciamento estados

O estado de gerenciamento de flutter se refere a todos  os objetos que ele usa para exibir suas ui ou gerencia recurso do sistema.
O gerenciamento de estado é como organizamos nossos aplicativo para acessar esses objetos de forma mais eficaz e compartilhá-los entre diferentes widgets.

* Usando um stateful widget
* Compartilhando estado entre widgets usando contrutures e InheritedWidget
* usando listenable para notificar outros

## Usando um stateful widget

A maneira mais simples de gerenciar o estado é usar um statefulWidget, que armazena o estado localmente, conforme o codigo abaixo:

```dart
class MyCounter extends StatefulWidget {
  const MyCounter({super.key});

  @override
  State<MyCounter> createState() => _MyCounterState();
}

class _MyCounterState extends State<MyCounter> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $count'),
        TextButton(
          onPressed: () {
            setState(() {
              count++;
            });
          },
          child: Text('Increment'),
        )
      ],
    );
  }
}
```

Este código ilustra dois conceitos importantes ao pensar sobre gerenciamento de estado:

* Encapsulamento : O widget que usa MyCounternão tem visibilidade da countvariável subjacente e não tem meios de acessá-la ou alterá-la.
* Ciclo de vida do objeto : O _MyCounterStateobjeto e sua countvariável são criados na primeira vez que MyCountersão construídos e existem até serem removidos da tela.

## Compartilhando estado entre widgets usando contrutures e InheritedWidget

Alguns cenários em que um aplicativo precisa armazenar estado incluem o seguinte:

* Para atualizar o estado compartilhado e notificar outras partes do aplicativo
* Para ouvir as alterações no estado compartilhado e reconstruir a IU quando ela for alterada

Esta seção explora como você pode efetivamente compartilhar o estado entre diferentes widgets no seu aplicativo. Os padrões mais comuns são:


* Usando construtores de widgets (às vezes chamados de "prop drilling" em outras estruturas)
* UsandoInheritedWidget (ou uma API semelhante, como o pacote provider ).
* Usando retornos de chamada para notificar um widget pai de que algo mudou

### Usando construtores de widgets

A maneira mais simples de compartilhar o estado é passá-lo para baixo na árvore de widgets usando construtores de widgets. Por exemplo, considere o seguinte aplicativo que exibe um contador e um botão que incrementa o contador:

```dart

class MyCounter extends StatelessWidget {
  final int count;
  const MyCounter({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Text('$count');
  }
}
```

Passar os dados compartilhados para seu aplicativo por meio de construtores de widget deixa claro para qualquer um que esteja lendo o código que há dependências compartilhadas. Esse é um padrão de design comum chamado injeção de dependência e muitas estruturas tiram vantagem dele ou fornecem ferramentas para facilitar.

### Usando InheritedWidget

Passar dados manualmente pela árvore de widgets pode ser prolixo e causar código clichê indesejado, então o Flutter fornece InheritedWidget, que fornece uma maneira de hospedar dados de forma eficiente em um widget pai para que os widgets filhos possam acessá-los sem armazená-los como um campo.

Para usar InheritedWidget, estenda a InheritedWidgetclasse e implemente o método estático of()usando dependOnInheritedWidgetOfExactType. Um widget chamando of()em um método de construção cria uma dependência que é gerenciada pelo framework Flutter, de modo que qualquer widget que dependa disso InheritedWidgetseja reconstruído quando esse widget for reconstruído com novos dados e updateShouldNotifyretornar true.

```dart
class MyState extends InheritedWidget {
  const MyState({
    super.key,
    required this.data,
    required super.child,
  });

  final String data;

  static MyState of(BuildContext context) {
    // This method looks for the nearest `MyState` widget ancestor.
    final result = context.dependOnInheritedWidgetOfExactType<MyState>();

    assert(result != null, 'No MyState found in context');

    return result!;
  }

  @override
  // This method should return true if the old widget's data is different
  // from this widget's data. If true, any widgets that depend on this widget
  // by calling `of()` will be re-built.
  bool updateShouldNotify(MyState oldWidget) => data != oldWidget.data;
}
```

Em seguida, chame o of()método do build()método do widget que precisa de acesso ao estado compartilhado:

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var data = MyState.of(context).data;
    return Scaffold(
      body: Center(
        child: Text(data),
      ),
    );
  }
}
```

### Retorno de chamadas

Você pode notificar outros widgets quando um valor muda expondo um callback. O Flutter fornece o ValueChangedtipo, que declara um callback de função com um único parâmetro:

```dart
typedef ValueChanged<T> = void Function(T value);

class MyCounter extends StatefulWidget {
  const MyCounter({super.key, required this.onChanged});

  final ValueChanged<int> onChanged;

  @override
  State<MyCounter> createState() => _MyCounterState();
}

TextButton(
  onPressed: () {
    widget.onChanged(count++);
  },
),

```

## Usando listenable para notificar outros

Agora que você escolheu como quer compartilhar o estado no seu aplicativo, como você atualiza a UI quando ela muda? Como você altera o estado compartilhado de uma forma que notifique outras partes do aplicativo?

O Flutter fornece uma classe abstrata chamada Listenableque pode atualizar um ou mais ouvintes. Algumas maneiras úteis de usar listenables são:

* Use um ChangeNotifiere assine-o usando um ListenableBuilder.
* Use um ValueNotifierpara armazenar um valor e assine-o usando um ValueListenableBuilder.

### ChangeNotifier

ChangeNotifieré uma classe que fornece um método notifyListeners()que notifica todos os ouvintes registrados. Você pode estender ChangeNotifierpara criar seu próprio objeto que notifica os ouvintes quando o estado muda.

```dart
class Counter extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
	_count++;
	notifyListeners();
  }
}
```

Em seguida, passe-o para ListenableBuilderpara garantir que a subárvore retornada pela builderfunção seja reconstruída sempre que ela ChangeNotifieratualizar seus ouvintes.

```dart
Column(
  children: [
    ListenableBuilder(
      listenable: counterNotifier,
      builder: (context, child) {
        return Text('counter: ${counterNotifier.count}');
      },
    ),
    TextButton(
      child: Text('Increment'),
      onPressed: () {
        counterNotifier.increment();
      },
    ),
  ],
)

```

### ValueNotifier

A ValueNotifieré uma versão mais simples de a ChangeNotifier, que armazena um único valor. Ele implementa as interfaces ValueListenablee Listenable, então é compatível com widgets como ListenableBuildere ValueListenableBuilder. Para usá-lo, crie uma instância de ValueNotifiercom o valor inicial:

```dart
final ValueNotifier<int> countNotifier = ValueNotifier<int>(0);
```

Em seguida, use o valuecampo para ler ou atualizar o valor e notificar quaisquer ouvintes de que o valor foi alterado. Como ValueNotifierextends ChangeNotifier, ele também é um Listenablee pode ser usado com um ListenableBuilder. Mas você também pode usar ValueListenableBuilder, que fornece o valor no builderretorno de chamada:

```dart
Column(
  children: [
    ValueListenableBuilder(
      valueListenable: counterNotifier,
      builder: (context, child, value) {
        return Text('counter: $value');
      },
    ),
    TextButton(
      child: Text('Increment'),
      onPressed: () {
        counterNotifier.value++;
      },
    ),
  ],
)
```

## Usando o mvvm

Agora que entendemos como compartilhar o estado e notificar outras partes do aplicativo quando seu estado muda, estamos prontos para começar a pensar em como organizar os objetos com estado em nosso aplicativo.

Esta seção descreve como implementar um padrão de design que funciona bem com estruturas reativas como o Flutter, chamado Model-View-ViewModel ou MVVM.

### Definindo o modelo

O Model é tipicamente uma classe Dart que faz tarefas de baixo nível, como fazer solicitações HTTP, armazenar dados em cache ou gerenciar recursos do sistema, como um plugin. Um model geralmente não precisa importar bibliotecas Flutter.


```dart
import 'package:http/http.dart';

class CounterData {
  CounterData(this.count);

  final int count;
}

class CounterModel {
  Future<CounterData> loadCountFromServer() async {
    final uri = Uri.parse('https://myfluttercounterapp.net/count');
    final response = await get(uri);

    if (response.statusCode != 200) {
      throw ('Failed to update resource');
    }

    return CounterData(int.parse(response.body));
  }

  Future<CounterData> updateCountOnServer(int newCount) async {
    // ...
  }
}

```

### Definindo o ViewModel

A ViewModelvincula a View ao Model . Ele protege o model de ser acessado diretamente pela View e garante que o fluxo de dados comece a partir de uma alteração no model. O fluxo de dados é manipulado pelo ViewModel, que usa notifyListenerspara informar a View que algo mudou. O ViewModelé como um garçom em um restaurante que lida com a comunicação entre a cozinha (model) e os clientes (views).

```dart
import 'package:flutter/foundation.dart';

class CounterViewModel extends ChangeNotifier {
  final CounterModel model;
  int? count;
  String? errorMessage;
  CounterViewModel(this.model);

  Future<void> init() async {
    try {
      count = (await model.loadCountFromServer()).count;
    } catch (e) {
      errorMessage = 'Could not initialize counter';
    }
    notifyListeners();
  }

  Future<void> increment() async {
    var count = this.count;
    if (count == null) {
      throw('Not initialized');
    }
    try {
      await model.updateCountOnServer(count + 1);
      count++;
    } catch(e) {
      errorMessage = 'Count not update count';
    }
    notifyListeners();
  }
}
```

### Definindo a View

Como nosso ViewModelé um ChangeNotifier, qualquer widget com uma referência a ele pode usar um ListenableBuilderpara reconstruir sua árvore de widgets quando o ViewModelnotifica seus ouvintes:

```dart
ListenableBuilder(
  listenable: viewModel,
  builder: (context, child) {
    return Column(
      children: [
        if (viewModel.errorMessage != null)
          Text(
            'Error: ${viewModel.errorMessage}',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.apply(color: Colors.red),
          ),
        Text('Count: ${viewModel.count}'),
        TextButton(
          onPressed: () {
            viewModel.increment();
          },
          child: Text('Increment'),
        ),
      ],
    );
  },
)
```


## usando o provider

O provider é uma biblioteca de gerenciamento de estado que fornece uma maneira de acessar e atualizar o estado em seu aplicativo. Ele é construído sobre o InheritedWidgete fornece uma maneira de acessar o estado sem ter que passá-lo manualmente pela árvore de widgets.


```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// This is a reimplementation of the default Flutter application using provider + [ChangeNotifier].

void main() {
  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Counter()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Mix-in [DiagnosticableTreeMixin] to have access to [debugFillProperties] for the devtool
// ignore: prefer_mixin
class Counter with ChangeNotifier, DiagnosticableTreeMixin {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('count', count));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),

            /// Extracted as a separate widget for performance optimization.
            /// As a separate widget, it will rebuild independently from [MyHomePage].
            ///
            /// This is totally optional (and rarely needed).
            /// Similarly, we could also use [Consumer] or [Selector].
            Count(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('increment_floatingActionButton'),

        /// Calls `context.read` instead of `context.watch` so that it does not rebuild
        /// when [Counter] changes.
        onPressed: () => context.read<Counter>().increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Count extends StatelessWidget {
  const Count({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      /// Calls `context.watch` to make [Count] rebuild when [Counter] changes.
      '${context.watch<Counter>().count}',
      key: const Key('counterState'),
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

```


o codigo acima é um exemplo de como usar o provider para gerenciar o estado de um aplicativo flutter, ele é uma maneira mais simples de gerenciar o estado de um aplicativo flutter, ele é construído sobre o InheritedWidgete fornece uma maneira de acessar o estado sem ter que passá-lo manualmente pela árvore de widgets.

### Diferença entre `context.watch` e `Consumer` no Flutter

#### 1. `context.watch`

**Descrição:**

- `context.watch<T>()` é usado para escutar mudanças de um provedor de tipo `T` e reconstruir o widget que o chama quando o valor do provedor muda.
- Ele é geralmente usado dentro do método `build` de um widget.

**Como funciona:**

- Quando você usa `context.watch<T>()`, o widget que o contém é automaticamente reconstruído toda vez que o provedor `T` muda.
- `context.watch` é simples e direto, mas pode ser menos eficiente em widgets complexos porque reconstrói o widget inteiro.

**Exemplo de Uso:**

```dart
class Count extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // O widget será reconstruído sempre que 'Counter' mudar
    final count = context.watch<Counter>().count;
    return Text(
      '$count',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
```

Neste exemplo, o widget `Count` é reconstruído sempre que o provedor `Counter` emite uma mudança.

#### 2. `Consumer`

**Descrição:**

- `Consumer` é um widget fornecido pelo pacote `provider` que permite escutar mudanças em um provedor sem reconstruir o widget inteiro.
- Ele oferece um controle mais granular sobre o que deve ser reconstruído quando um provedor muda.

**Como funciona:**

- `Consumer` utiliza um `builder` que fornece acesso ao modelo e ao contexto. O `builder` é chamado sempre que o provedor muda.
- Somente o widget dentro do `Consumer` é reconstruído, permitindo otimização de desempenho, especialmente em widgets complexos ou grandes.

**Exemplo de Uso:**

```dart
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
      ),
      body: Center(
        child: Consumer<Counter>(
          builder: (context, counter, child) {
            return Text(
              '${counter.count}',
              style: Theme.of(context).textTheme.headlineMedium,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<Counter>().increment(),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
```

Neste exemplo, apenas o widget dentro de `Consumer<Counter>` é reconstruído quando o provedor `Counter` muda, enquanto o resto da árvore do widget permanece inalterado.

### Diferenças e Quando Usar

1. **Rebuild Completo vs. Parcial**:
   - `context.watch` reconstrói o widget inteiro onde é chamado. É útil para widgets simples ou onde o rebuild completo não é um problema.
   - `Consumer` reconstrói apenas a parte do widget que é necessária, ideal para widgets complexos ou grandes onde você deseja evitar reconstruções desnecessárias.

2. **Uso Prático**:
   - Use `context.watch` para simplicidade quando o desempenho não é uma preocupação.
   - Use `Consumer` para maior controle e eficiência, especialmente em árvores de widgets mais complexas ou aninhadas.

Ambas as abordagens fazem parte da mesma biblioteca e são usadas para ouvir mudanças de provedores, mas oferecem diferentes níveis de controle sobre a reconstrução de widgets.
