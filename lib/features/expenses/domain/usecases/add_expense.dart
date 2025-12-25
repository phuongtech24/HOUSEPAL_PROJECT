import '../entities/expense.dart';
import '../repositories/expenses_repository.dart';

class AddExpense {
  final ExpensesRepository repository;
  AddExpense(this.repository);

  Future<void> call(Expense expense) async {
    return repository.addExpense(expense);
  }
}
