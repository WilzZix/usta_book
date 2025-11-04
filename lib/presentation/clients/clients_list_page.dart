import 'package:flutter/material.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

import '../../core/ui_kit/components/inputs/search_bar.dart';

class ClientsListPage extends StatefulWidget {
  const ClientsListPage({super.key});

  static const String tag = '/clients-page';

  @override
  State<ClientsListPage> createState() => _ClientsListPageState();
}

class _ClientsListPageState extends State<ClientsListPage> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mijozlar', style: Typographies.boldH1),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: SearchBarWidget(controller: searchController),
        ),
      ),
      body: SingleChildScrollView(child: Column(children: [])),
    );
  }
}
