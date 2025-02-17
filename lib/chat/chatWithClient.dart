import 'dart:async';
import 'dart:math';
import 'package:booking_calendar/booking_calendar.dart'hide BookingService;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happy_tails/UserManage/model/booking.dart';
import 'package:happy_tails/UserManage/providers/profile_providers.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:happy_tails/app/routes.dart';
import 'package:happy_tails/chat/chatRepository.dart';
import 'package:happy_tails/chat/message_model.dart';
import 'package:happy_tails/homeProvider/providers.dart';
import 'package:happy_tails/payment_service.dart';
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

enum Urgency { none, low, medium, high } // Define urgency levels

Urgency _getUrgency(int daysUntilBooking) {
  if (daysUntilBooking > 7) {
    return Urgency.none;
  } else if (daysUntilBooking > 3) {
    return Urgency.low;
  } else if (daysUntilBooking > 1) {
    return Urgency.medium;
  } else {
    return Urgency.high;
  }
}

Color _getUrgencyColor(Urgency urgency, ThemeData theme) {
  switch (urgency) {
    case Urgency.none:
      return Colors.grey; // Or a neutral color
    case Urgency.low:
      return Colors.blue; // Or another appropriate color
    case Urgency.medium:
      return Colors.orange;
    case Urgency.high:
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String _getUrgencyLabel(Urgency urgency) {
  switch (urgency) {
    case Urgency.none:
      return "";
    case Urgency.low:
      return "Bassa Urgenza";
    case Urgency.medium:
      return "Media Urgenza";
    case Urgency.high:
      return "Alta Urgenza";
    default:
      return "";
  }
}


// Updated ChatPage with preserved logic + new features
class ChatWithClientPage extends ConsumerWidget {
  const ChatWithClientPage({Key? key, required this.clientId}) : super(key: key);
  final String clientId;
 static Route<void> route(String clientId) { // Added booking parameter
    return MaterialPageRoute(
      builder: (context) => ChatWithClientPage(clientId: clientId),
    );
  }

  @override
 Widget build(BuildContext context, WidgetRef ref) {
  final messagesState = ref.watch(chatProvider(clientId));
  final chatNotifier = ref.read(chatProvider(clientId).notifier);
  final bookingState = ref.watch(bookingNotifierProvider);
  if (bookingState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookingState.errorMessage != null) {
      return Center(child: Text('Error: ${bookingState.errorMessage}'));
    }

  final bookings = bookingState.groupedBookings[clientId];
  if (bookings != null) { // Make sure bookings is not null before sorting
  bookings.sort((a, b) {
    // Define the sorting logic
    if (a.state == "Richiesta" && b.state != "Richiesta") {
      return -1; // a comes before b (Richiesta comes first)
    } else if (a.state != "Richiesta" && b.state == "Richiesta") {
      return 1;  // b comes before a (Richiesta comes first)
    } else {
      return 0;  // a and b are considered equal in terms of "Richiesta" state
                  // We can add further sorting criteria here if needed,
                  // for example, by another field or by their original order.
    }
  });}
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(context, bookings![0].owner_username??""),
        actions: const [_HeaderMenuButton()],
      ),
      body: Column(
        children: [
          PetsitterBookingCard(booking: bookings[0]),
          Expanded(
            child: messagesState.when(
              data: (messages) => _MessageList(
                messages: messages,
                clientId: clientId,
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
                receiver_id: clientId,
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
        
       
}

  Widget _buildAppBarTitle(context, String client_name) {
  return GestureDetector(
    onTap: () => Navigator.pushNamed(
 context,
AppRoutes.sitterpage,
arguments: [client_name,[],DateTimeRange(
  start: DateTime.now(),
  end: DateTime.now().add(const Duration(days: 1))
)],// Pass the pet sitter
 ),
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      //leading: CircleAvatar(backgroundImage: NetworkImage(sitter.imageUrl)),
      title: Text(client_name),
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
  final String clientId;
  final VoidCallback onRefresh;

  const _MessageList({
    required this.messages,
    required this.clientId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: messages.isEmpty
          ? const Center(child: Text('Inizia la conversazione'))
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






// Petsitter Booking Card with Actionable State
class PetsitterBookingCard extends ConsumerStatefulWidget {
  final Booking booking;
  
  const PetsitterBookingCard({Key? key, required this.booking}) : super(key: key);

  @override
  ConsumerState<PetsitterBookingCard> createState() => _PetsitterBookingCardState();
}

class _PetsitterBookingCardState extends ConsumerState<PetsitterBookingCard> {
  /// Represents whether a process is ongoing.
  /// null means not processing, 'accepting' or 'declining' indicates the current action.
  String? _processingState;
  
  bool get _isProcessing => _processingState != null;
  double _cardElevation = 2;
  final Duration _elevationDuration = const Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysUntilBooking = _calculateDaysRemaining(widget.booking.dateBegin);
    
    
    return MouseRegion(
      onEnter: (_) => setState(() => _cardElevation = 4),
      onExit: (_) => setState(() => _cardElevation = 2),
      child: AnimatedContainer(
        duration: _elevationDuration,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.15),
              blurRadius: _cardElevation * 2,
              spreadRadius: _cardElevation * 0.5,
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(daysUntilBooking, theme),
              const SizedBox(height: 16),
              _buildTimelineIndicator(widget.booking.dateBegin),
              const SizedBox(height: 24),
              _buildPetAndClientInfo(),
              if (widget.booking.summary != null) _buildSummarySection(theme),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
Widget _buildUrgencyBadge(int daysUntilBooking, ThemeData theme) {
  final urgency = _getUrgency(daysUntilBooking); // Helper function (see below)
  final color = _getUrgencyColor(urgency, theme);  // Helper function (see below)

  if (urgency == Urgency.none) { // Don't show badge if no urgency
    return const SizedBox.shrink(); // Empty widget
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2), // Subtle background
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      _getUrgencyLabel(urgency), // Helper function (see below)
      style: theme.textTheme.labelSmall?.copyWith(color: color), // Matching text color
    ),
  );
}
  Widget _buildHeaderSection(int daysUntilBooking, ThemeData theme) {
    Color color;
    String label;
    switch (widget.booking.state) {
    case "Richiesta":
      color = Colors.orange;
      label = "Richiesta"; // Or a localized version
      break;
    case "Confermata":
      color = Colors.green;
      label = "Confermata"; // Or a localized version
      break;
    case "Rifiutata":
      color = Colors.red;
      label = "Rifiutata"; // Or a localized version
      break;
    default:
      color = Colors.grey; // Default color for unknown statuses
      label = "Sconosciuto"; // Or a localized "Unknown"
      break;
  }

    return Row(
      children: [
        _buildStatusIndicator(label, color, theme),
        const Spacer(),
        _buildUrgencyBadge(daysUntilBooking, theme),
      ],
    );
  }
  

  Widget _buildStatusIndicator(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 10),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

Color _getProgressColor(double progress) {
  // Define your color gradient or logic here.
  // This example uses a simple gradient from green to yellow.

  if (progress <= 0) return Colors.grey; // Handle cases before start
  if (progress >= 1) return Colors.green; // Handle cases after completion

  // Calculate an intermediate color based on the progress.
  // You can customize the color ranges and logic as needed.

  int red = (255 * progress).toInt();  // Red increases with progress
  int green = 255;                   // Green stays constant (full)
  int blue = 0;                      // Blue stays constant (none)

  return Color.fromRGBO(red, green, blue, 1); // Build the color

}

  Widget _buildTimelineIndicator(String startDate) {
    final daysRemaining = _calculateDaysRemaining(startDate);
    final bookingProgress = _calculateProgressValue(startDate);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inizio prenotazione: ${_formatDate(startDate)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: bookingProgress,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          color: _getProgressColor(bookingProgress),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          daysRemaining > 0 
              ? 'Tra $daysRemaining ${daysRemaining == 1 ? 'giorno' : 'giorni'}'
              : 'Oggi',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: _getUrgencyTextColor(daysRemaining),
          ),
        ),
      ],
    );
  }

  Widget _buildPetAndClientInfo() {
    return Column(
      children: [
        _InfoTile(
          icon: Icons.pets,
          title: 'Animale',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nome: ${widget.booking.pet_name}'),
              Text('Tipo: ${widget.booking.pet_type}'),
              /*if (widget.booking.pet != null)
                Text('Note: ${widget.booking.petNotes}'),*/
            ],
          ),
        ),
        const Divider(height: 32),
        _InfoTile(
          icon: Icons.person,
          title: 'Cliente',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.booking.owner_username??""),
              /*if (widget.booking.clientNotes != null)
                Text('Richiesta speciali: ${widget.booking.clientNotes}'),*/
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (widget.booking.state != "Richiesta") {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            icon: const Icon(Icons.check_circle, size: 20),
            label: const Text('Accetta Prenotazione'),
            onPressed: () => _handleBookingResponse(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.cancel, size: 20),
            label: const Text('Rifiuta Prenotazione'),
            onPressed: () => _showDeclineConfirmationDialog(),
          ),
          
        ),
      ],
    );
  }

  Widget _buildSummarySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Note speciali del cliente:',
            style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(widget.booking.summary!,
              style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
void _showStatusChangeError(String errorMessage) {
  // Check if the widget is still mounted before using context
  if (!mounted) {
    print("Warning: Widget is unmounted, cannot show SnackBar.");
    return; // Do nothing if the widget is unmounted
  }

  // 1. Find the relevant context (usually the Scaffold or a key'd widget)
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  // 2. Create a SnackBar with a clear message and an optional action
  scaffoldMessenger.showSnackBar(
    SnackBar(
      content: Row( // Use a Row for better layout
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error), // Distinctive icon
          const SizedBox(width: 8),
          Expanded( // Expand the text to handle longer messages
            child: Text(
              errorMessage,
              style: TextStyle(color: Theme.of(context).colorScheme.onError), // Error color
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 5), // Adjust duration as needed
      behavior: SnackBarBehavior.floating, // Modern floating behavior
      shape: RoundedRectangleBorder( // Rounded corners for a softer look
        borderRadius: BorderRadius.circular(8),
      ),
      action: SnackBarAction( // Optional action (e.g., Retry)
        label: 'Riprova', // Localized label
        textColor: Theme.of(context).colorScheme.onError,
        onPressed: () {
          // Handle retry logic here (e.g., call _handleBookingResponse again)
          _handleBookingResponse(true); // Or whatever action is appropriate
        },
      ),
    ),
  );
}
void _handleBookingResponse(bool accepted) async {
  if (widget.booking.state != 'Richiesta') return;

  if (_isProcessing) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confermi di ${accepted ? 'accettare' : 'rifiutare'} ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Torna Indietro'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confermo'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  setState(() => _processingState = accepted ? 'accepting' : 'declining');

  try {
    final success = await ref.read(bookingNotifierProvider.notifier)
        .respondToBooking(widget.booking.id, accepted: accepted);
    if (!success) throw Exception('Failed');
    if(accepted){
      await PaymentService.capturePayment(widget.booking.metaPayment!);
    }else{
      await PaymentService.cancelPayment(widget.booking.metaPayment!);
    }

  } catch (e) {
    _showStatusChangeError("Error");
  } finally {
  }
}

  void _showDeclineConfirmationDialog() {
    TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma rifiuto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Invia una motivazione al cliente:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Es. Disponibilità già piena...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                HapticFeedback.vibrate();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inserisci una motivazione')),
                );
                return;
              }
              Navigator.pop(context);
              _handleBookingResponse(false);
            },
            child: const Text('Conferma rifiuto'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationAnimation(bool accepted) {
    final color = accepted ? Colors.green : Colors.red;
    const icon = Icons.check_circle_outline;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => PopScope(
        canPop: false,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: 1,
          child: AlertDialog(
            backgroundColor: color.withOpacity(0.1),
            icon: Icon(icon, size: 48, color: color),
            content: Text(
              accepted 
                ? 'Prenotazione confermata con successo!'
                : 'Richiesta rifiutata con successo',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
  }
  void _showActionError(String errorMessage, {VoidCallback? onRetry}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface, // Use a surface color
      shape: RoundedRectangleBorder( // Rounded corners
        borderRadius: BorderRadius.circular(16),
      ),
      icon: Icon(
        Icons.error_outline,
        size: 64, // Larger icon
        color: Theme.of(context).colorScheme.error,
      ),
      title: Text(
        "Errore", // Localized title
        style: Theme.of(context).textTheme.headlineSmall?.copyWith( // Style the title
          color: Theme.of(context).colorScheme.error,
        ),
        textAlign: TextAlign.center,
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 16.0), // Add padding to the top of the content
        child: Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium, // Use bodyMedium for content
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: const Text('Riprova'),
          ),
      ],
    ),
  );

}

  // Helper Methods
  int _calculateDaysRemaining(String date) {
    final now = DateTime.now();
    final target = DateTime.parse(date);
    return target.difference(now).inDays;
  }

  String _formatDate(String date) {
    final dt = DateTime.parse(date);
    return DateFormat('dd MMM yyyy').format(dt);
  }

  Color _getUrgencyTextColor(int days) {
    return days > 7 
        ? Colors.green
        : days > 3 
          ? Colors.orange 
          : Colors.red;
  }

  double _calculateProgressValue(String startDate) {
    final totalDays = DateTime.parse(widget.booking.dateBegin)
        .difference(DateTime.parse(startDate))
        .inDays
        .abs();
        
    final daysPassed = DateTime.now()
        .difference(DateTime.parse(widget.booking.dateEnd))
        .inDays;
        
    return (daysPassed / totalDays).clamp(0.0, 1.0);
  }
}

// Reusable Info Tile Component
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget content;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, 
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 4),
              content,
            ],
          ),
        ),
      ],
    );
  }
}
