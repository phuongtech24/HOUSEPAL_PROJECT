import '../entities/expense.dart';
import '../repositories/expenses_repository.dart';

class GetExpenses {
  final ExpensesRepository repository;
  GetExpenses(this.repository);

  Future<List<Expense>> call() async {
    return repository.getExpenses();
  }
}
