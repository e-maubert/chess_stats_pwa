import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chess_stats_viewmodel.dart';
import 'stats_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _searchStats() {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<ChessStatsViewModel>();
      viewModel.fetchStats(_usernameController.text).then((_) {
        if (viewModel.error == null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StatsPage(),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Stats PWA'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Chess.com Username',
                    hintText: 'Enter your Chess.com username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Consumer<ChessStatsViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      onPressed: _searchStats,
                      child: const Text('Search Stats'),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Consumer<ChessStatsViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.error != null) {
                      return Text(
                        viewModel.error!,
                        style: const TextStyle(color: Colors.red),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 