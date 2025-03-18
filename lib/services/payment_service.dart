import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  late Razorpay _razorpay;

  factory PaymentService() {
    return _instance;
  }

  PaymentService._internal() {
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void startPayment({
    required double amount,
    required String orderName,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) {
    try {
      var options = {
        'key': 'rzp_live_3XlZxl6S2KSrdr',
        'amount': (amount * 100).toInt(),
        'name': orderName,
        'description': 'Payment for food order',
        'timeout': 300, // in seconds
        'prefill': {
          'contact': customerPhone,
          'email': customerEmail,
          'name': customerName,
        },
        'external': {
          'wallets': ['paytm']
        },
        'theme': {'color': '#FF5722'},
        // UPI specific options
        'method': {
          'upi': true,
          'netbanking': true,
          'card': true,
          'wallet': true,
        },
        'upi_flow': 'collect',
        'remember_customer': true,
        'send_sms_hash': true,
        'currency': 'INR',
      };

      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      Fluttertoast.showToast(
        msg: "Error initializing payment: $e",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');
    Fluttertoast.showToast(
      msg: "Payment Successful!\nPayment ID: ${response.paymentId}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.message}');
    Fluttertoast.showToast(
      msg: "Payment Failed: ${response.message ?? 'Error occurred'}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    Fluttertoast.showToast(
      msg: "External Wallet Selected: ${response.walletName}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
    );
  }

  void dispose() {
    _razorpay.clear();
  }
}
