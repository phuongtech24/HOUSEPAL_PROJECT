import '../entities/expense.dart';

abstract class ExpensesRepository {
  Future<List<Expense>> getExpenses();
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense(String id);
}
