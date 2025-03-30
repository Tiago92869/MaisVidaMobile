import 'package:testtest/services/medicine/medicine_service.dart';
import 'package:testtest/services/medicine/medicine_model.dart';

class MedicineRepository {
  final MedicineService _medicineService = MedicineService();

  Future<MedicinePage> getMedicines(bool archived, int page, int size) async {
    try {
      print('Requesting medicines: archived=$archived, page=$page, size=$size');
      final medicinePage = await _medicineService.fetchMedicines(archived, page, size);
      print('Successfully fetched medicines: ${medicinePage.content.length} items');
      return medicinePage;
    } catch (e) {
      print('Error fetching medicines: $e');
      rethrow; // Re-throw the error to be handled by the caller
    }
  }

  Future<Medicine> getMedicineById(String id) async {
    try {
      print('Requesting medicine by ID: $id');
      final medicine = await _medicineService.fetchMedicineById(id);
      print('Successfully fetched medicine: ${medicine.name}');
      return medicine;
    } catch (e) {
      print('Error fetching medicine by ID: $e');
      rethrow;
    }
  }

  Future<Medicine> addMedicine(Medicine medicine) async {
    try {
      print('Adding new medicine: ${medicine.name}');
      final addedMedicine = await _medicineService.createMedicine(medicine);
      print('Successfully added medicine: ${addedMedicine.name}');
      return addedMedicine;
    } catch (e) {
      print('Error adding medicine: $e');
      rethrow;
    }
  }

  Future<Medicine> updateMedicine(String id, Medicine medicine) async {
    try {
      print('Updating medicine ID: $id');
      final updatedMedicine = await _medicineService.modifyMedicine(id, medicine);
      print('Successfully updated medicine: ${updatedMedicine.name}');
      return updatedMedicine;
    } catch (e) {
      print('Error updating medicine: $e');
      rethrow;
    }
  }

  Future<void> removeMedicine(String id) async {
    try {
      print('Removing medicine ID: $id');
      await _medicineService.deleteMedicine(id);
      print('Successfully removed medicine ID: $id');
    } catch (e) {
      print('Error removing medicine: $e');
      rethrow;
    }
  }
}
