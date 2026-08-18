import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_state_widgets.dart';
import '../providers/consultant_provider.dart';
import '../widgets/consultant_card.dart';

class ConsultantListPage extends ConsumerWidget {
  const ConsultantListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consultants = ref.watch(consultantListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Konsultan')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(consultantListProvider),
        child: consultants.when(
          data: (items) {
            if (items.isEmpty) {
              return const AppEmptyState(
                title: 'Belum ada konsultan',
                message: 'Katalog konsultan akan tampil setelah data tersedia.',
              );
            }
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SearchBar(
                  hintText: 'Cari Konsultan',
                  leading: Icon(Icons.search),
                ),
                const SizedBox(height: 16),
                ...items.map((item) => ConsultantCard(consultant: item)),
              ],
            );
          },
          error: (error, _) => AppErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(consultantListProvider),
          ),
          loading: () => const AppLoading(),
        ),
      ),
    );
  }
}
