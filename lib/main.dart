import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ' Sushant Pokemon Marketplace',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        textTheme: TextTheme(
          headline6: TextStyle(color: Colors.black87, fontSize: 18.0, fontWeight: FontWeight.bold),
          subtitle1: TextStyle(color: Colors.black54, fontSize: 16.0),
          subtitle2: TextStyle(color: Colors.black45, fontSize: 14.0),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          shadowColor: Colors.teal.shade200,
          elevation: 5,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.teal.shade300,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: PokemonList(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PokemonList extends StatefulWidget {
  @override
  _PokemonListState createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  List<dynamic> pokemonData = [];

  @override
  void initState() {
    super.initState();
    fetchPokemonData();
  }

  Future<void> fetchPokemonData() async {
    final Uri url = Uri.parse('https://api.pokemontcg.io/v2/cards?q=name:gardevoir');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        pokemonData = json.decode(response.body)['data'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' Sushant Pokemon Marketplace'),
      ),
      body: ListView.builder(
        itemCount: pokemonData.length,
        itemBuilder: (BuildContext context, int index) {
          final pokemon = pokemonData[index];
          final marketPrice = pokemon['tcgplayer']['prices']['holofoil']['market'];
          return Card(
            margin: EdgeInsets.all(10.0),
            child: ListTile(
              leading: Image.network(pokemon['images']['small']),
              title: Text(pokemon['name'], style: Theme.of(context).textTheme.headline6),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Market Price: \$${marketPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.subtitle1),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showPaymentDialog(context),
                    child: Text('Buy Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade300,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
        selectedItemColor: Colors.teal.shade800,
        unselectedItemColor: Colors.teal.shade400,
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Card Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Card Number',
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Expiration Date',
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'CVV',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => _navigateToPaymentSuccess(context),
              child: Text('Pay Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToPaymentSuccess(BuildContext context) {
    Navigator.pop(context); // Close dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessPage(),
      ),
    );
  }
}

class PaymentSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Successful'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate back to shopping list
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: Text('Buy Another One'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
