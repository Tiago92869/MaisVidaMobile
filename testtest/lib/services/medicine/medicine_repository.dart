import 'package:testtest/services/medicine/medicine_service.dart';
import 'package:testtest/services/medicine/medicine_model.dart';

class MedicineRepository {
  final MedicineService _medicineService = MedicineService();

  Future<MedicinePage> getMedicines(
    bool archived,
    DateTime startDate,
    DateTime endDate, {
    int page = 0,
    int size = 10,
  }) async {
    return await _medicineService.fetchMedicines(
      archived,
      startDate,
      endDate,
      page: page,
      size: size,
    );
  }

  Future<Medicine> getMedicineById(String id) async {
    return await _medicineService.fetchMedicineById(id);
  }

  Future<void> createMedicine(MedicineCreate medicineCreate) async {
    await _medicineService.createMedicine(medicineCreate);
  }

  Future<Medicine> updateMedicine(String id, Medicine medicine) async {
    return await _medicineService.modifyMedicine(id, medicine);
  }

  Future<void> deleteMedicine(String id) async {
    await _medicineService.deleteMedicine(id);
  }
}
