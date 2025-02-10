import 'package:get/get.dart';
import '../models/pr_list_model.dart';
import '../services/helper/request_services.dart';

class PRApprovalsController extends GetxController {
  final RequestServices services = RequestServices();
  var purchaseRequests = Rx<PurchaseRequestSet?>(null);
  var isRefreshTriggered = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPurchaseRequests();
  }

  Future<void> fetchPurchaseRequests() async {
    try {
      var data = await services.fetchPurchaseRequest();
      purchaseRequests.value = data;
    } catch (e) {
      // Handle error
      print('Error fetching purchase requests: $e');
    }
  }

  Future<void> refresh() async {
    await Future.delayed(Duration(seconds: 2));
    fetchPurchaseRequests();
    isRefreshTriggered.value = false;
  }
}
