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
  String? _cardNumber;
  String? _expiryMonth;
  String? _expiryYear;
  String? _cvv;
  String? _nameOnCard;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        // Step 1: Crea il PaymentMethod
        final paymentMethod = await Stripe.instance.createPaymentMethod(
          params : PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: BillingDetails(

              ),
            ),
          ),
        );
        print(paymentMethod.id);
        print(widget.customerId);
        // Step 2: Associa la carta al cliente su Stripe via backend
        await PaymentService.attachPaymentMethod(paymentMethod.id, widget.customerId);
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Gestisce la tastiera
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              'Aggiungi Metodo di Pagamento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: 'Nome sul titolare della carta'),
              onSaved: (value) => _nameOnCard = value,
              validator: (value) => value == null || value.isEmpty ? 'Inserisci il nome' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Numero della carta'),
              keyboardType: TextInputType.number,
              onSaved: (value) => _cardNumber = value,
              validator: (value) => value == null || value.isEmpty ? 'Inserisci il numero della carta' : null,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Mese di scadenza (MM)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _expiryMonth = value,
                    validator: (value) => value == null || value.isEmpty ? 'Inserisci il mese' : null,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Anno di scadenza (YY)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _expiryYear = value,
                    validator: (value) => value == null || value.isEmpty ? 'Inserisci l\'anno' : null,
                  ),
                ),
              ],
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'CVV'),
              keyboardType: TextInputType.number,
              onSaved: (value) => _cvv = value,
              validator: (value) => value == null || value.isEmpty ? 'Inserisci il CVV' : null,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Aggiungi Metodo di Pagamento'),
            ),
          ],
        ),
      ),
    );
  }
}