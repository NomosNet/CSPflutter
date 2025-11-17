import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Практика 3',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Практика 3'),
        backgroundColor: Colors.blue, // Цвет AppBar
      ),
      body: Column(
        children: [
          // Текст с приветствием
          const Text(
            'Добро пожаловать в Flutter!',
            style: TextStyle(
              fontSize: 24, // Размер шрифта
              fontWeight: FontWeight.bold, // Жирный текст
              color: Color(0xFF2E7D32), // Кастомный зеленый цвет
            ),
          ),
          
          // Отступ
          const SizedBox(height: 20),
          
          // Кнопка
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Цвет кнопки
            ),
            child: const Text('Нажми меня'),
          ),
          
          // Отступ
          const SizedBox(height: 20),
          
          // Контейнер
          Container(
            width: 200,
            height: 100,
            color: const Color(0xFFFF6D00), // Кастомный оранжевый цвет
          ),
          
          // Отступ
          const SizedBox(height: 20),
          
          // Row с иконками
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.star,
                color: Colors.yellow,
                size: 40,
              ),
              SizedBox(width: 20), // Отступ между иконками
              Icon(
                Icons.favorite,
                color: Colors.red,
                size: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }
}