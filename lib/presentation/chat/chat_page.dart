import 'dart:math';
import 'package:flutter/material.dart';

// O'zingizni importlaringizni joyida qoldiring:
// import 'package:usta_book/core/ui_kit/colors.dart';
// import 'package:usta_book/core/ui_kit/components/inputs/inputs.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  static const String tag = '/chat-page';

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.grey, // AppColors.secondaryBg o'rniga test uchun
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Icon(Icons.person)),
              ),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User'),
                Text('Last seen at 4:00 Am', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      // DIQQAT: Tashqaridagi Padding olib tashlandi, chunki u Sliverlar bilan konflikt beradi
      body: CustomScrollView(
        reverse: true,
        // ALOHIDA SHART: Chat pastdan tepaga qarab o'sishi va input ustida turishi uchun
        slivers: [
          // Tashqaridagi Padding o'rniga SliverPadding ishlatamiz
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList.separated(
              itemCount: 25,
              itemBuilder: (context, index) {
                final isMe = index % 2 != 0;
                return Row(
                  mainAxisAlignment: isMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.teal : Colors.grey[200],
                        // O'zingizni AppColors ranglaringizni qo'ying
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Message $index',
                        // Random o'rniga index qo'ydim, scroll payti o'zgarib ketmasligi uchun
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 16);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                8, // Klaviaturadan qochish va qo'shimcha joy
          ),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Message',
              border: OutlineInputBorder(),
            ),
          ), // O'zingizni InputField.text vidjetingizni qaytarib qo'ying
        ),
      ),
    );
  }
}
