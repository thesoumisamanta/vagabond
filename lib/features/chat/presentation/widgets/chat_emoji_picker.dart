import 'package:flutter/material.dart';
import 'package:vagabond/features/chat/presentation/widgets/whatsapp_theme.dart';

class ChatEmojiPicker extends StatefulWidget {
  final ValueChanged<String> onEmojiSelected;
  final VoidCallback onBackspace;

  const ChatEmojiPicker({
    super.key,
    required this.onEmojiSelected,
    required this.onBackspace,
  });

  @override
  State<ChatEmojiPicker> createState() => _ChatEmojiPickerState();
}

class _ChatEmojiPickerState extends State<ChatEmojiPicker> {
  int _selectedCategoryIndex = 0;
  final PageController _pageController = PageController();

  static const List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.sentiment_satisfied_alt_outlined,
      'name': 'Smileys',
      'emojis': [
        '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '🥲', '🥹',
        '☺️', '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰', '😘',
        '😗', '😙', '😚', '😋', '😛', '😝', '😜', '🤪', '🤨', '🧐',
        '🤓', '😎', '🥸', '🤩', '🥳', '😏', '😒', '😞', '😔', '😟',
        '😕', '🙁', '☹️', '😣', '😖', '😫', '😩', '🥺', '😢', '😭',
        '😮‍💨', '😤', '😠', '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱',
        '😨', '😰', '😥', '😓', '🫣', '🤗', '🫡', '🤔', '🫢', '🤭',
        '🤫', '🤥', '😶', '😐', '😑', '😬', '🫠', '🙄', '😯', '😦',
        '😧', '😮', '😲', '🥱', '😴', '🤤', '😪', '😵', '😵‍💫', '🤐',
        '🥴', '🤢', '🤮', '🤧', '😷', '🤒', '🤕', '🤑', '🤠', '😈',
        '👿', '👹', '👺', '🤡', '💩', '👻', '💀', '☠️', '👽', '👾',
        '🤖', '🎃'
      ],
    },
    {
      'icon': Icons.waving_hand_outlined,
      'name': 'People & Gestures',
      'emojis': [
        '👋', '🤚', '🖐️', '✋', '🖖', '🫱', '🫲', '🫳', '🫴', '👌',
        '🤌', '🤏', '✌️', '🤞', '🫰', '🤟', '🤘', '🤙', '👈', '👉',
        '👆', '🖕', '👇', '☝️', '🫵', '👍', '👎', '✊', '👊', '🤛',
        '🤜', '👏', '🙌', '🫶', '👐', '🤲', '🤝', '🙏', '✍️', '💅',
        '🤳', '💪', '🦾', '🦿', '🦵', '🦶', '👂', '🦻', '👃', '🫀',
        '🫁', '🧠', '🦷', '🦴', '👀', '👁️', '👅', '👄', '🫦', '👶',
        '🧒', '👦', '👧', '🧑', '👱', '👨', '🧔', '👩', '🧓', '👴', '👵'
      ],
    },
    {
      'icon': Icons.pets_outlined,
      'name': 'Animals & Nature',
      'emojis': [
        '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐻‍❄️', '🐨',
        '🐯', '🦁', '🐮', '🐷', '🐸', '🐵', '🙈', '🙉', '🙊', '🐒',
        '🐔', '🐧', '🐦', '🐤', '🐣', '🐥', '🦆', '🦅', '🦉', '🦇',
        '🐺', '🐗', '🐴', '🦄', '🐝', '🪱', '🐛', '🦋', '🐌', '🐞',
        '🐜', '🪰', '🪲', '🪳', '🪴', '🌲', '🌳', '🌴', '🪵', '🌵',
        '🌾', '🌿', '☘️', '🍀', '🍁', '🍂', '🍃', '🍄', '🌰', '🦀',
        '🦞', '🦐', '🦑', '🐙', '🪼', '🐡', '🐠', '🐟', '🐬', '🐳',
        '🐋', '🦈', '🐊', '🐅', '🐆', '🦓', '🦍', '🦧', '🦣', '🐘',
        '🦛', '🦏', '🐪', '🐫', '🦒', '🦘', '🦬', '🐃', '🐂', '🐄'
      ],
    },
    {
      'icon': Icons.fastfood_outlined,
      'name': 'Food & Drink',
      'emojis': [
        '🍏', '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🫐',
        '🍈', '🍒', '🍑', '🥭', '🍍', '🥥', '🥝', '🍅', '🍆', '🥑',
        '🥦', '🥬', '🥒', '🌶️', '🫑', '🌽', '🥕', '🫒', '🧄', '🧅',
        '🥔', '🍠', '🥐', '🥯', '🍞', '🥖', '🥨', '🧀', '🥚', '🍳',
        '🧈', '🥞', '🧇', '🥓', '🥩', '🍗', '🍖', '🌭', '🍔', '🍟',
        '🍕', '🫓', '🥪', '🥙', '🧆', '🌮', '🌯', '🫔', '🥗', '🥘',
        '🍝', '🍜', '🍲', '🍛', '🍣', '🍱', '🥟', '🦪', '🍤', '🍙',
        '🍧', '🍨', '🍦', '🥧', '🧁', '🍰', '🎂', '🍮', '🍭', '🍬',
        '🍫', '🍿', '🍩', '🍪', '☕', '🫖', '🍵', '🧃', '🥤', '🧋',
        '🍺', '🍻', '🥂', '🍷', '🥃', '🍸', '🍹', '🍾', '🧊'
      ],
    },
    {
      'icon': Icons.flight_takeoff_outlined,
      'name': 'Travel & Places',
      'emojis': [
        '✈️', '🛫', '🛬', '🛩️', '🚁', '🚟', '🚠', '🚡', '🛰️', '🚀',
        '🛸', '🚂', '🚆', '🚄', '🚅', '🚈', '🚇', '🚊', '🚝', '🚞',
        '🚋', '🚌', '🚍', '🚎', '🚐', '🚑', '🚒', '🚓', '🚔', '🚕',
        '🚖', '🚗', '🚘', '🚙', '🛻', '🚚', '🚛', '🚜', '🏎️', '🏍️',
        '🛵', '🚲', '🛴', '🛹', '🛼', '⛺', '🏕️', '🏖️', '🏜️', '🏝️',
        '🏞️', '🏟️', '🏛️', '🏗️', '🏘️', '🏠', '🏡', '🏢', '🏣', '🏤',
        '🏥', '🏦', '🏨', '🏩', '🏪', '🏫', '🏬', '🏯', '🏰', '🗼',
        '🗽', '⛪', '🕌', '🛕', '⛩️', '⛲', '🌁', '🌃', '🏙️', '🌄',
        '🌅', '🌆', '🌇', '🌉', '♨️', '🎠', '🎡', '🎢', '💈', '🎪'
      ],
    },
    {
      'icon': Icons.sports_soccer_outlined,
      'name': 'Activities',
      'emojis': [
        '⚽', '🏀', '🏈', '⚾', '🥎', '🎾', '🏐', '🏉', '🥏', '🎱',
        '🪀', '🏓', '🏸', '🏒', '🏑', '🥍', '🏏', '🪃', '🥅', '⛳',
        '🪁', '🏹', '🎣', '🤿', '🥊', '🥋', '🎽', '🛹', '🛼', '🛷',
        '⛸️', '🎿', '⛷️', '🏂', '🪂', '🏋️', '🤼', '🤸', '🤺', '⛹️',
        '🤾', '🧗', '🧘', '🏄', '🏊', '🤽', '🚣', '🚴', '🏆', '🥇',
        '🥈', '🥉', '🏅', '🎖️', '🎫', '🎟️', '🎪', '🤹', '🎭', '🎨',
        '🎬', '🎤', '🎧', '🎼', '🎹', '🥁', '🎷', '🎺', '🎸', '🎻',
        '🎲', '🎯', '🎳', '🎮', '🎰', '🧩'
      ],
    },
    {
      'icon': Icons.favorite_border_rounded,
      'name': 'Symbols & Hearts',
      'emojis': [
        '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔',
        '❤️‍🔥', '❤️‍🩹', '❣️', '💕', '💞', '💓', '💗', '💖', '💘', '💝',
        '💟', '☮️', '✝️', '☪️', '🕉️', '☸️', '✡️', '🔯', '🕎', '☯️',
        '☦️', '🛐', '⛎', '♈', '♉', '♊', '♋', '♌', '♍', '♎',
        '♏', '♐', '♑', '♒', '♓', '🆔', '⚛️', '🉑', '☢️', '☣️',
        '📴', '📳', '🈶', '🈚', '🈸', '🈺', '🈷️', '✴️', '🆚', '💮',
        '🉐', '㊙️', '㊗️', '🈴', '🈵', '🈹', '🈲', '🅰️', '🅱️', '🆎',
        '🆑', '🅾️', '🆘', '❌', '⭕', '🛑', '⛔', '📛', '🚫', '💯',
        '💢', '♨️', '🚷', '🚯', '🚳', '🚱', '🔞', '📵', '🚭', '❗',
        '❕', '❓', '❔', '‼️', '⁉️', '⚠️', '🚸', '🔱', '⚜️', '🔰',
        '♻️', '✅', '❇️', '✳️', '❎', '🌐', '💠', 'Ⓜ️', '🌀', '💤'
      ],
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCategoryTapped(int index) {
    setState(() => _selectedCategoryIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      color: WhatsAppTheme.cardBackground,
      child: Column(
        children: [
          // Top Category Tabs
          Container(
            height: 42,
            color: WhatsAppTheme.headerBackground.withOpacity(0.5),
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedCategoryIndex == index;
                      final category = _categories[index];
                      return GestureDetector(
                        onTap: () => _onCategoryTapped(index),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isSelected ? WhatsAppTheme.primaryGreen : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                          child: Icon(
                            category['icon'] as IconData,
                            size: 22,
                            color: isSelected ? WhatsAppTheme.primaryGreen : WhatsAppTheme.iconGrey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Backspace action in category bar
                IconButton(
                  icon: const Icon(Icons.backspace_outlined, color: WhatsAppTheme.iconGrey, size: 20),
                  onPressed: widget.onBackspace,
                ),
              ],
            ),
          ),

          // Emojis PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _categories.length,
              onPageChanged: (index) {
                setState(() => _selectedCategoryIndex = index);
              },
              itemBuilder: (context, catIndex) {
                final List<String> emojis = _categories[catIndex]['emojis'] as List<String>;
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: emojis.length,
                  itemBuilder: (context, index) {
                    final emoji = emojis[index];
                    return GestureDetector(
                      onTap: () => widget.onEmojiSelected(emoji),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

