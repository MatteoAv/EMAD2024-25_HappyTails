import 'package:flutter/material.dart';
import 'package:happy_tails/Auth/EncryptService.dart';
import 'package:happy_tails/UserManage/widgets/AddCardFormModal.dart';
import 'package:happy_tails/payment_service.dart';


class PaymentMethodsPage extends StatefulWidget {
  final String customerId;

  const PaymentMethodsPage({Key? key, required this.customerId}) : super(key: key);

  @override
  _PaymentMethodsPageState createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = true;
  final encrypter = EncryptionService();

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
  }

  Future<void> _fetchPaymentMethods() async {
    final customerId = widget.customerId;
    final methods = await PaymentService.getPaymentMethods(customerId);
    setState(() {
      _paymentMethods = methods;
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Metodi di pagamento'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _paymentMethods.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.credit_card_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Nessun metodo di pagamento salvato.',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _paymentMethods.length,
                          itemBuilder: (context, index) {
                            final method = _paymentMethods[index];
                            return ListTile(
                              leading: Icon(Icons.credit_card, color: Colors.blue),
                              title: Text('${method['card']['brand']} **** ${method['card']['last4']}'),
                              subtitle: Text('Scadenza: ${method['card']['exp_month']}/${method['card']['exp_year']}'),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                // Qui puoi aggiungere azioni per modificare o eliminare il metodo
                                print('Metodo selezionato: ${method['id']}');
                              },
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      //print(widget.customerId);
                      showModalBottomSheet(context: context,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => AddCardFormModal(
                        customerId : widget.customerId,
                        onCardAdded: (){
                          _fetchPaymentMethods();
                        },
                      ),
                      );
                    },
                    icon: Icon(Icons.add),
                    label: Text('Aggiungi metodo di pagamento'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}