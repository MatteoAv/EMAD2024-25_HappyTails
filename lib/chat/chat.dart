import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happy_tails/UserManage/model/booking.dart';
import 'package:happy_tails/UserManage/providers/profile_providers.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:happy_tails/app/routes.dart';
import 'package:happy_tails/chat/chatRepository.dart';
import 'package:happy_tails/chat/message_model.dart';
import 'package:happy_tails/homeProvider/providers.dart';
import 'package:happy_tails/screens/ricerca/petsitter_model.dart';
import 'package:happy_tails/screens/ricerca/petsitter_page.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart';
import 'package:sqflite/sqflite.dart'; // For SQLite
import 'package:riverpod/riverpod.dart'; // State management
import 'package:shimmer/shimmer.dart';

import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'chat_provider.dart';

final petSitterProvider = FutureProvider.family<PetSitter, String>((ref, petSitterId) async {
  print('Fetching PetSitter with ID: $petSitterId'); // Debug print
  
  final response = await Supabase.instance.client
      .from('petsitter')
      .select()
      .eq('uuid', petSitterId)
      .single();
      
  print('Supabase response: $response'); // Debug print
print("fdsjjbdsjfjdjsf");
  if (response == null) {
    throw Exception('PetSitter not found');
  }
  
  return PetSitter.fromMap(response);
});


// Updated ChatPage with preserved logic + new features
class ChatPage extends ConsumerWidget {
  const ChatPage({Key? key, required this.otherUserId}) : super(key: key);
  final String otherUserId;
  static Route<void> route(String otherUserId) {
    return MaterialPageRoute(
      builder: (context) => ChatPage(otherUserId: otherUserId),
    );
  }

  @override
 Widget build(BuildContext context, WidgetRef ref) {
  final messagesState = ref.watch(chatProvider(otherUserId));
  final chatNotifier = ref.read(chatProvider(otherUserId).notifier);

  return ref.watch(petSitterProvider(otherUserId)).when(
    data: (petSitter) {
      return ref.watch(bookingsProvider).when(
        data: (bookings) {
          final filteredList = bookings
              .where((booking) => booking.petsitter_id == petSitter.id)
              .toList()
            ..sort((a, b) => b.dateBegin.compareTo(a.dateBegin));
          print("fdsdfj");

          if (filteredList.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: _buildAppBarTitle(context, petSitter),
                actions: const [_HeaderMenuButton()],
              ),
              body: const Center(child: Text('No bookings found')),
            );
          }

          final booking = filteredList.first;

          return Scaffold(
            appBar: AppBar(
              title: _buildAppBarTitle(context, petSitter),
              actions: const [_HeaderMenuButton()],
            ),
            body: Column(
              children: [
                _BookingHeader(booking: booking, petsitter: petSitter,),
                Expanded(
                  child: messagesState.when(
                    data: (messages) => _MessageList(
                      messages: messages,
                      otherUserId: otherUserId,
                      onRefresh: () {},
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text('Error: $error')),
                  ),
                ),
                _MessageBar(
                  onSend: (text) {
                    final myUserId = Supabase.instance.client.auth.currentUser!.id;
                    final message = Message(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      sender_id: myUserId,
                      receiver_id: otherUserId,
                      content: text,
                      timestamp: DateTime.now(),
                      status: 'unsynced',
                    );
                    chatNotifier.sendMessage(message);
                  },
                ),
              ],
            ),
          );
        },
        loading: () => Scaffold(
          appBar: AppBar(title: _buildAppBarTitle(context, petSitter)),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => Scaffold(
          appBar: AppBar(title: _buildAppBarTitle(context, petSitter)),
          body: Center(child: Text('Error: $error')),
        ),
      );
    },
    loading: () => const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    ),
    error: (error, stackTrace) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Error: $error')),
    ),
  );
}

  Widget _buildAppBarTitle(context, PetSitter sitter) {
    print(sitter.nome);
    print("ddsfhuiaf");
  return GestureDetector(
    onTap: () => Navigator.pushNamed(
 context,
AppRoutes.sitterpage,
arguments: [sitter,[],DateTimeRange(
  start: DateTime.now(),
  end: DateTime.now().add(const Duration(days: 1))
)],// Pass the pet sitter
 ),
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundImage: NetworkImage(sitter.imageUrl)),
      title: Text(sitter.nome),
      /*subtitle: Text('Attivo', style: TextStyle(
        color: Colors.green.shade500,
        fontSize: 12
        
      )),
    */),
  );
}
}

class _MessageBar extends StatefulWidget {
  const _MessageBar({Key? key, required this.onSend}) : super(key: key);
  final void Function(String) onSend;

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Scrivi un messaggio',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  final text = _textController.text.trim();
                  if (text.isNotEmpty) {
                    widget.onSend(text);
                    _textController.clear();
                  }
                },
                child: const Text('Invia'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Preserved MessageList with pull-to-refresh
class _MessageList extends StatelessWidget {
  final List<Message> messages;
  final String otherUserId;
  final VoidCallback onRefresh;

  const _MessageList({
    required this.messages,
    required this.otherUserId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: messages.isEmpty
          ? const Center(child: Text('Start your conversation now :)'))
          : ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _ChatBubble(
                  message: message,
                  isMine: message.sender_id == Supabase.instance.client.auth.currentUser!.id,
                );
              },
            ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({Key? key, required this.message, required this.isMine}) : super(key: key);

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    List<Widget> chatContents = [
      if (!isMine) const CircleAvatar(child: Text('U')),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isMine ? Colors.orange[200] : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content),
        ),
      ),
      const SizedBox(width: 12),
      Text(format(message.timestamp, locale: 'en_short')),
    ];
    if (isMine) chatContents = chatContents.reversed.toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }
}

// Header Menu Button (3-dot menu)
class _HeaderMenuButton extends StatelessWidget {
  const _HeaderMenuButton();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('View Profile'),
          ),
        ),
        const PopupMenuItem(
          value: 'report',
          child: ListTile(
            leading: Icon(Icons.flag),
            title: Text('Report User'),
          ),
        ),
      ],
    );
  }
}
class _BookingHeader extends StatelessWidget {
  final Booking booking;
  final PetSitter petsitter;

  const _BookingHeader({required this.booking, required this.petsitter});

  @override
  Widget build(BuildContext context) {
    final status = _determineStatus(booking);
    
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _AnimatedStatusChip(status: status),
                const Spacer(),
                _HoverIconButton(
                  icon: Icons.info_outline_rounded,
                  onPressed: () => _showBookingDetails(context, booking, petsitter),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InteractiveTimeline(booking: booking),
          ],
        ),
      ),
    );
  }

  String _determineStatus(Booking booking) {
    final now = DateTime.now();
    final endDate = DateTime.parse(booking.dateEnd);
    return now.isAfter(endDate) ? 'Terminata' : booking.state;
  }
}

class _AnimatedStatusChip extends StatefulWidget {
  final String status;

  const _AnimatedStatusChip({required this.status});

  @override
  State<_AnimatedStatusChip> createState() => _AnimatedStatusChipState();
}

class _AnimatedStatusChipState extends State<_AnimatedStatusChip> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedStatusChip oldWidget) {
    if (oldWidget.status != widget.status) {
      _controller.reset();
      _controller.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final (color, text, icon) = switch (widget.status) {
      'Richiesta' => (
          Colors.amber.shade600,
          'In attesa',
          Icons.access_time_filled_rounded
        ),
      'Rifiutata' => (
          Colors.red.shade600,
          'Rifiutata',
          Icons.cancel_rounded
        ),
      'Confermata' => (
          Colors.green.shade600,
          'Confermata',
          Icons.check_circle_rounded
        ),
      'Terminata' => (
          Colors.blueGrey,
          'Completata',
          Icons.verified_rounded
        ),
      _ => (
          Colors.grey,
          'Unknown',
          Icons.error_outline_rounded
        ),
    };

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (widget.status == 'Richiesta')
                    _PulsingDot(color: color),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InteractiveTimeline extends StatelessWidget {
  final Booking booking;

  const _InteractiveTimeline({required this.booking});

  @override
  Widget build(BuildContext context) {
    final start = DateTime.parse(booking.dateBegin);
    final end = DateTime.parse(booking.dateEnd);
    final now = DateTime.now();
    final progress = _calculateProgress(start, end, now);

    return Column(
      children: [
        _AnimatedProgressIndicator(progress: progress),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TimelineStep(
              date: start,
              label: 'Inizio',
              isActive: true,
              icon: Icons.play_circle_filled_rounded,
            ),
            _TimelineStep(
              date: end,
              label: 'Fine',
              isActive: now.isAfter(start),
              icon: Icons.flag_circle_rounded,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _PriceBadge(price: booking.price),
      ],
    );
  }

  double _calculateProgress(DateTime start, DateTime end, DateTime now) {
    final total = end.difference(start).inSeconds;
    final current = now.difference(start).inSeconds;
    return (current / total).clamp(0.0, 1.0);
  }
}

class _AnimatedProgressIndicator extends ImplicitlyAnimatedWidget {
  final double progress;

  const _AnimatedProgressIndicator({
    required this.progress,
  }) : super(duration: const Duration(milliseconds: 800));

  @override
  ImplicitlyAnimatedWidgetState<_AnimatedProgressIndicator> createState() => 
      _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState 
    extends AnimatedWidgetBaseState<_AnimatedProgressIndicator> {
  Tween<double>? _progressTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _progressTween = visitor(
      _progressTween,
      widget.progress,
      (value) => Tween<double>(begin: value as double),
    ) as Tween<double>;
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: _progressTween?.evaluate(animation) ?? 0,
      backgroundColor: Colors.grey.shade200,
      valueColor: AlwaysStoppedAnimation(
        Theme.of(context).colorScheme.primary.withOpacity(0.6),
      ),
      minHeight: 8,
      borderRadius: BorderRadius.circular(8),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final DateTime date;
  final String label;
  final bool isActive;
  final IconData icon;

  const _TimelineStep({
    required this.date,
    required this.label,
    required this.isActive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: '${DateFormat('EEEE, d MMMM').format(date)}\n${DateFormat('HH:mm').format(date)}',
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.grey.shade300,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isActive 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isActive 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              DateFormat('d MMM').format(date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceBadge extends StatelessWidget {
  final double price;

  const _PriceBadge({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '€${price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            TextSpan(
              text: ' totale',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
class _PulsingDot extends StatefulWidget {
  final Color color;

  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  // Add this dispose method
  @override
  void dispose() {
    _controller.dispose(); // Critical cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      ),
      child: Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}









// Enhanced Hover Icon Button with Micro-Interactions
class _HoverIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  const _HoverIconButton({
    required this.icon,
    required this.onPressed,
    this.size = 24,
  });

  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onPressed();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: _isHovered 
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  widget.icon,
                  size: widget.size,
                  color: _isHovered 
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).iconTheme.color,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleHover(bool hovering) {
    setState(() => _isHovered = hovering);
    hovering ? _controller.forward() : _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Premium Booking Details Modal
void _showBookingDetails(BuildContext context, Booking booking, PetSitter petsitter) {
  final theme = Theme.of(context);
  final paymentState = _parsePaymentState(booking.state_Payment);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, booking),
              const SizedBox(height: 24),
              _buildTimelineSection(booking),
              const SizedBox(height: 16),
              //_buildPaymentStatus(paymentState),
              if (booking.summary != null) _buildSummarySection(theme),
              if (booking.vote != null) _buildRatingSection(theme),
              const SizedBox(height: 24),
              _buildActionButtons(context, booking, petsitter),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildHeader(ThemeData theme, Booking booking) {
  return Row(
    children: [
      Hero(
        tag: 'booking-${booking.id}',
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.calendar_month, color: theme.primaryColor),
        ),
      ),
      const SizedBox(width: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prenotazione #${booking.id_trans}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${_formatDate(booking.dateBegin)} - ${_formatDate(booking.dateEnd)}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    ],
  );
}

Widget _buildTimelineSection(Booking booking) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _DetailTile(
        icon: Icons.pets,
        title: 'Animale',
        value: 'ID: ${booking.pet_id}',
      ),
      _DetailTile(
        icon: Icons.person,
        title: 'Pet Sitter',
        value: 'ID: ${booking.petsitter_id}',
      ),
      _DetailTile(
        icon: Icons.euro_symbol,
        title: 'Totale',
        value: '€${booking.price.toStringAsFixed(2)}',
      ),
    ],
  );
}

Widget _buildPaymentStatus((Color, IconData, String) paymentState) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: paymentState.$1.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(paymentState.$2, color: paymentState.$1),
        const SizedBox(width: 12),
        Text(
          paymentState.$3,
          style: TextStyle(
            color: paymentState.$1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget _buildSummarySection(ThemeData theme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      Text(
        'Note della Prenotazione',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        
      ),
    ],
  );
}

Widget _buildRatingSection(ThemeData theme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      Text(
        'Valutazione',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          ...List.generate(5, (index) => Icon(
            index < 1/*booking.vote! */? Icons.star_rounded : Icons.star_outline_rounded,
            color: Colors.amber,
            size: 20,
          )),
        ],
      ),
    ],
  );
}

Widget _buildActionButtons(BuildContext context, Booking booking, PetSitter sitter) {
  return Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          icon: const Icon(Icons.person),
          label: const Text('Profilo Pet Sitter'),
          onPressed: () => Navigator.pushNamed(
 context,
AppRoutes.sitterpage,
arguments: [sitter,[],DateTimeRange(
  start: DateTime.now(),
  end: DateTime.now().add(const Duration(days: 1))
)],// Pass the pet sitter
 ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: FilledButton.icon(
          icon: const Icon(Icons.receipt),
          label: const Text('Ricevuta'),
          onPressed: () => ""//_handleReceiptDownload(booking),
        ),
      ),
    ],
  );
}

(String, IconData, Color) _parsePaymentState(String state) {
  return switch (state.toLowerCase()) {
    'completato' => ('Pagamento Completato', Icons.check_circle, Colors.green),
    'in_attesa' => ('Pagamento in Attesa', Icons.pending, Colors.orange),
    'fallito' => ('Pagamento Fallito', Icons.error, Colors.red),
    'rimborsato' => ('Rimborsato', Icons.currency_exchange, Colors.blue),
    _ => ('Sconosciuto', Icons.help, Colors.grey),
  };
}

String _formatDate(String date) {
  final dt = DateTime.parse(date);
  return DateFormat('dd/MM/yy HH:mm').format(dt);
}

// Reusable Detail Tile Component
class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.labelSmall),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}













