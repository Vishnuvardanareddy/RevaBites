import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:reva_bites/models/cart_item.dart';
import 'package:reva_bites/services/order_service.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  late Razorpay _razorpay;
  final OrderService _orderService = OrderService();

  // Store cart data and restaurant ID for order creation
  String? _currentRestaurantId;
  Map<String, CartItem>? _currentCartItems;
  Function? _onOrderSuccess;

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
    required String restaurantId,
    required Map<String, CartItem> cartItems,
    Function? onOrderSuccess,
  }) {
    try {
      // Store data for order creation after payment
      _currentRestaurantId = restaurantId;
      _currentCartItems = cartItems;
      _onOrderSuccess = onOrderSuccess;

      var options = {
        'key': 'rzp_test_CmexjmP8mBTor6',
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

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      debugPrint('Payment Success: ${response.paymentId}');

      // Create order in Supabase after successful payment
      if (_currentRestaurantId != null && _currentCartItems != null) {
        final orderId = await _orderService.createOrder(
          restaurantId: _currentRestaurantId!,
          cartItems: _currentCartItems!,
          status: 'pending', // Set initial status as pending
        );

        debugPrint('Order created successfully: $orderId');

        // Call the success callback if provided
        if (_onOrderSuccess != null) {
          _onOrderSuccess!();
        }

        // Clear stored data
        _currentRestaurantId = null;
        _currentCartItems = null;
        _onOrderSuccess = null;
      }

      Fluttertoast.showToast(
        msg: "Payment Successful!\nPayment ID: ${response.paymentId}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      debugPrint('Error creating order: $e');
      Fluttertoast.showToast(
        msg: "Payment successful but failed to create order: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.message}');

    // Clear stored data
    _currentRestaurantId = null;
    _currentCartItems = null;
    _onOrderSuccess = null;

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
