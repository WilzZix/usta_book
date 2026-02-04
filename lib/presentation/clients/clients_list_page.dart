import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usta_book/bloc/clients/clients_bloc.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

import '../../core/localization/i18n/strings.g.dart';
import '../../core/ui_kit/app_theme_extension.dart';
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
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    final tr = Translations.of(context);
    return Scaffold(
      backgroundColor: custom.body,
      appBar: AppBar(
        backgroundColor: custom.body,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(tr.clients.customers, style: Typographies.boldH1),
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
            SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(child: Text(tr.clients.customer_list, style: Typographies.semiBoldH2)),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
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
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: MainButton.primary(title: tr.clients.add_new_customer, icon: Icon(Icons.add)),
            ),
          ],
        ),
      ),
    );
  }
}
