import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:happy_tails/payment_service.dart';

class AddCardFormModal extends StatefulWidget {
  final String customerId;
  final VoidCallback onCardAdded;

  const AddCardFormModal({Key? key, required this.customerId, required this.onCardAdded}) : super(key: key);

  @override
  _AddCardFormModalState createState() => _AddCardFormModalState();
}

class _AddCardFormModalState extends State<AddCardFormModal> {
  final _formKey = GlobalKey<FormState>();
  final CardEditController _cardController = CardEditController();
  bool _isProcessing = false;

  Future<void> _submit() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // Creazione del PaymentMethod
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(name: "Test User"),
          ),
        ),
      );

      // Associa il metodo al cliente
      await PaymentService.attachPaymentMethod(paymentMethod.id, widget.customerId);

      widget.onCardAdded();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Aggiungi Metodo di Pagamento',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: CardField(
                controller: _cardController,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _submit,
              icon: Icon(Icons.credit_card),
              label: _isProcessing
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Salva Carta'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}