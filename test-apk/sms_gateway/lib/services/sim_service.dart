import 'package:sim_data/sim_data.dart';

class SimService {
  // Get all available SIM cards
  Future<List<SimCard>> getAvailableSims() async {
    try {
      final simData = await SimDataPlugin.getSimData();
      return simData.cards;
    } catch (e) {
      print('Error getting SIM cards: $e');
      return [];
    }
  }

  // Get selected SIM or auto-select if single SIM
  Future<SimCard?> getSelectedSim(int? savedSubscriptionId) async {
    final sims = await getAvailableSims();

    if (sims.isEmpty) return null;

    // If single SIM, return it
    if (sims.length == 1) return sims.first;

    // If subscription ID is saved, find matching SIM
    if (savedSubscriptionId != null) {
      try {
        return sims.firstWhere(
          (sim) => sim.subscriptionId == savedSubscriptionId,
        );
      } catch (e) {
        // If saved SIM not found, return first SIM
        return sims.first;
      }
    }

    // Return first SIM as default
    return sims.first;
  }

  // Check if device has dual SIM
  Future<bool> isDualSim() async {
    final sims = await getAvailableSims();
    return sims.length > 1;
  }

  // Get SIM display name
  String getSimDisplayName(SimCard sim) {
    final carrier =
        sim.carrierName.isNotEmpty ? sim.carrierName : 'Unknown Carrier';
    final number = sim.serialNumber.isNotEmpty ? sim.serialNumber : 'No Number';
    return '$carrier - $number';
  }
}
