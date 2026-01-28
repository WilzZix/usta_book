import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usta_book/bloc/clients/clients_bloc.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/domain/extension/extensions.dart';

import '../../core/ui_kit/components/app_icons.dart';
import '../../core/ui_kit/components/inputs/search_bar.dart';
import 'components/client_item.dart';

class ClientsListPage extends StatefulWidget {
  const ClientsListPage({super.key});

  static const String tag = '/clients-page';

  @override
  State<ClientsListPage> createState() => _ClientsListPageState();
}

class _ClientsListPageState extends State<ClientsListPage> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ClientsBloc>(context).add(GetClientsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.body,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('Mijozlar', style: Typographies.boldH1),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: SearchBarWidget(controller: searchController),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: Text("Mijozlar ro'yhati", style: Typographies.semiBoldH2)),
            BlocBuilder<ClientsBloc, ClientsState>(
              builder: (context, state) {
                switch (state) {
                  case ClientsInitial():
                    return SliverToBoxAdapter(child: SizedBox());
                  case ClientsListLoaded():
                    return SliverList.builder(
                      itemBuilder: (context, index) {
                        return ClientItem(data: state.data[0]);
                      },
                      itemCount: state.data.length,
                    );
                  case ClientsListLoading():
                    return SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                  case ClientsListLoadError():
                    return SliverToBoxAdapter(child: Center(child: Text(state.msg)));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
