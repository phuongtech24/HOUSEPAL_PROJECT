import '../repositories/expenses_repository.dart';

class DeleteExpense {
  final ExpensesRepository repository;
  DeleteExpense(this.repository);

  Future<void> call(String id) async {
    return repository.deleteExpense(id);
  }
}
